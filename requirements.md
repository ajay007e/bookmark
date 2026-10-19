# Bookmark: requirements

## Overview
Bookmark is a personal Android app for tracking books, movies and series.
No login or accounts. All data lives in a local database on the phone.

## Environment
- Ubuntu, Flutter installed with snap, Android Studio as the editor (not VS Code)
- I am new to Flutter and Dart: explain commands and new concepts briefly
- Give complete files with the file path above each one, and tell me how to run and check each step
- Build in small steps

## Stack
- Flutter (Android only), Dart package name `bookmark`, app display name "Bookmark"
- Drift (SQLite) for the local database, with drift_flutter. Schema version 2.
- flutter_riverpod for state
- go_router for navigation (item detail screens)
- cached_network_image for posters and covers
- dio for API calls
- url_launcher for the "Watch now" links
- Planned: workmanager (new-episode checks)
- Data sources: TMDB (movies, series, episodes, streaming availability; free API key kept in lib/config/secrets.dart, gitignored) and Open Library (books)
- Streaming availability comes from TMDB's watch-provider data, which is supplied by JustWatch.
  Shown for Australia only (`watchRegion = 'AU'` in tmdb_client.dart) with the credit line
  "Streaming data by JustWatch, via TMDB."

## Statuses
One enum in code: want, inProgress, done, dropped.
- Movies and series: Want to watch, Watching, Watched
- Books: Want to read, Reading, Read, Did not complete
- Series are tracked per episode (season number, episode number, watched flag and date)
- Did not complete books: optional reason and page stopped at
- Books have no page-progress tracking. Only the stop page is recorded, when a book is not completed.

### Series status rules
- A series with no ticked episodes is Want to watch.
- The first ticked episode moves it to Watching automatically.
- A series that is still running (TMDB: Returning Series, In Production, Planned, Pilot) is never
  Watched. It stays Watching, even when every aired episode is ticked. If the show status is not
  known yet it is treated as running. The status is saved the first time the series page loads.
- A series that has ended becomes Watched when every aired episode is ticked.
- Unticking every episode moves it back to Want to watch.
- Episodes that have not aired cannot be ticked.
- Ticking an episode while earlier aired episodes are unticked asks "Mark earlier episodes too?"
  (earlier episodes in the same season and in earlier seasons). Episodes marked this way are
  saved as watched earlier (see Watch history).

## Tick button and watch history
Detail pages for movies, series and books have a round tick button beside the title. There is no
status dropdown.
- **Look:** grey outline = not started, coloured ring with an icon = Watching/Reading, filled =
  done, red with a block icon = Did not complete. The long-press sheet shows the status in words.
- **Tap:** movie or book = watched/read now. Tapping again when done asks to undo.
  Series that has ended = asks to mark all aired episodes watched now; tapping again when Watched
  asks to unmark everything. Series still running = a sheet asks "Watched now" or
  "Watched earlier", then marks all aired episodes (status stays Watching).
- **Long press** (movies, series, books, not episodes) opens a sheet:
    - Movie: Add to wishlist, Watched now (Watched again now), Watched earlier, Mark as unwatched, Remove.
    - Series: Add to wishlist, Watched now, Watched earlier, Mark as unwatched, Remove.
      For a running series the two watched options mark the aired episodes.
    - Book: Want to read, Reading, Read now (Read again now), Read earlier, Did not complete,
      Mark as unread, Remove. Movies have no "Watching" option.
- **Watched now** counts in the watch time. **Watched earlier** is saved but not counted.
- **Episodes** only have watched / not watched, with their own tick (no long press). A ticked
  episode counts as watched now.
- **History (WatchLogs):** every mark writes a row (item, episode for series, time, counted flag,
  minutes). Rewatching a movie or book adds another row. "Mark as unwatched" removes the latest
  row of a movie or book (the status goes back to Want only when no rows are left). For a series it
  unticks all episodes and removes their rows. Things added through the search sheet as
  Watched/Read are saved as earlier. Items marked before this feature have no rows.
- Runtime is stored when known (movies, series episode length, each episode) so watch time can be
  calculated later.

## Input rules
- Searching titles by typing is fine
- Everything else is selection: ticks, menus, chips, sliders, fixed lists of reasons
- Typing is allowed only as an option where needed (for example a custom stop reason)
- Details (title, poster, genres, episodes, authors, ratings, cast) come from TMDB / Open Library, not manual entry
- No personal rating or review. The `rating` column exists in the database but is unused.

## Extra features
- Tags, genres and custom lists
- Backup: export everything to a JSON file and import it back (including the watch history)
- Planned: watch-time statistics from the watch history (counted entries only)

## Home screen
1. Hero carousel with large posters (about 60% of the screen height): series being watched,
   series with a new episode available, and the book being read
2. Recently watched movies and series
3. Recently read books

"New episode available" shows on a series when it has an aired, unticked episode that aired after
your last activity on that series (or it is a Watched series with an aired, unticked episode).
Otherwise a series shows "Watching".

Wish lists are not on Home. They are available through the "Want to ..." status filter on the
Books, Movies and Series screens.

Navigation: bottom bar with Home, Books, Movies, Series, Library.

## Detail pages
Opened from any poster or hero card (`/item/:id`). All use a large HD poster header that collapses
into the app bar, with a round back button. The title row is "Name (year)" with the tick button on
the right; the button never makes the row taller than the title.
- Rating shown as a coloured ring (green 7+/10 or 3.5+/5, amber, red).
- Details are fetched when the page opens. If offline, the saved info still shows with a short note.
- Sections are separated by thin lines (Cast, Similar).
- "You may also like" row: tap an item in the library to open it, or a new one to add it.

**Movie** (top to bottom): title (year) + tick; rating ring | line 1: age rating · duration, line 2:
release date (country) · original language · status; categories; Watch now (Stream, Free, Rent,
Buy with logos in Australia; a logo opens TMDB's watch page); tagline; overview; Director | Writer;
Cast; Similar. Age rating: Australia first, then US. Release date: Australian cinema release, then
US, then the general date.

**Series** has two tabs.
- **Details tab:** title (year) + tick; rating ring | line 1: age rating, line 2: original language ·
  status (Ongoing/Ended); categories; Watch now; tagline; overview; Creator; Cast; Similar.
- **Episodes tab:** a plain app bar with the tabs, then a row of season cards (poster, Season n,
  watched/total, rating · year · n episodes, overview or "Aired x of y episodes", progress bar)
  that scrolls sideways and stays pinned at the top. Below it the episodes of the selected season
  scroll on their own. The tab opens on the season of the last watched episode (the furthest
  ticked one) with that episode at the top of the list; with nothing ticked it opens on season 1.
  Tapping a season card shows that season from episode 1. Each episode shows image, n. title,
  rating · air date · runtime, description (tap to expand) and its own tick. "Mark season as
  watched / unwatched" sits above the list.

**Book** (top to bottom): title (year) + tick; by Author; rating ring | pages · language ·
publisher (from the most prominent English edition); categories; "Did not complete" card (reason,
page stopped at, edit) when it applies; About this book; Similar.
"Did not complete" opens a sheet with reason chips (plus optional "Other" text) and a
page-stopped-at slider with -10/-1/+1/+10 buttons. Both are optional and can be edited later.
Recommendations: other books by the same author plus top-rated books in one of the book's subjects.

## Data model (Drift tables, schema version 2)
- MediaItems: one table for movie, series and book (type, externalId, title, posterUrl, overview, year, genres, status, rating, runtime, ongoing, author, pageCount, currentPage, dropReason, droppedAtPage, addedAt, lastActivityAt). Unique on (type, externalId). `rating` and `currentPage` are unused. `runtime` is minutes (movie length or typical episode length). `ongoing` is null until known.
- Episodes: seriesId, seasonNumber, episodeNumber, title, airDate, runtime, watched, watchedAt. Unique on (seriesId, seasonNumber, episodeNumber).
- WatchLogs: itemId, episodeId (null for movies and books), watchedAt, counted (true = watched now, false = watched earlier), minutes.
- UserLists and ListEntries: custom lists and tags, many-to-many with items

Posters are stored as medium images. Detail pages and the hero swap the URL for a larger version
at display time (TMDB w780, Open Library -L).

## Progress
- [x] Flutter and Android Studio setup
- [x] Project skeleton, Drift database, home screen, list screens
- [x] TMDB and Open Library search and add flow (status picker, episodes fetched for series)
- [x] Empty states with animated illustration (replaces the sample data button)
- [x] go_router, tappable posters and hero, bigger hero, wish lists removed from Home
- [x] Movie, book and series detail pages
- [x] "You may also like" on movie, series and book pages
- [x] Tick button with long-press options, watch history (WatchLogs), database schema 2
- [x] Series status rules (running series stay Watching)
- [x] Redesigned detail layouts, Watch now (Australia)
- [x] Series Details and Episodes tabs (pinned season cards, last watched episode at the top)
- [ ] Daily background check for new episodes (workmanager). Also refreshes the saved episode list,
  since episodes are currently only fetched once when a series is added.
- [ ] Lists and tags screen (Library tab)
- [ ] JSON export and import (include the watch history)
- [ ] Watch-time statistics