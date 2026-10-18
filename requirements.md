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
- Drift (SQLite) for the local database, with drift_flutter
- flutter_riverpod for state
- go_router for navigation (detail and season screens)
- cached_network_image for posters and covers
- dio for API calls
- Planned: workmanager (new-episode checks)
- Data sources: TMDB (movies, series, episodes; free API key kept in lib/config/secrets.dart, gitignored) and Open Library (books)

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
- When every aired episode is ticked it becomes Watched. A Watched series with a newly aired,
  unticked episode shows "New episode available" in the Home hero.
- Unticking every episode moves it back to Want to watch.
- Episodes that have not aired cannot be ticked.
- Ticking an episode while earlier aired episodes are unticked asks "Mark earlier episodes too?"
  (applies to earlier episodes in the same season and in earlier seasons).
- Choosing Watched in the dropdown asks to confirm, then ticks all aired episodes.
- Choosing Want to watch on a started series asks to confirm, then clears all ticks.

## Input rules
- Searching titles by typing is fine
- Everything else is selection: status dropdowns, chips, sliders, fixed lists of reasons
- Typing is allowed only as an option where needed (for example a custom stop reason)
- Details (title, poster, genres, episodes, authors, ratings, cast) come from TMDB / Open Library, not manual entry
- No personal rating or review. The `rating` column exists in the database but is unused.

## Extra features
- Tags, genres and custom lists
- Backup: export everything to a JSON file and import it back

## Home screen
1. Hero carousel with large posters (about 60% of the screen height): series being watched,
   series with a new episode available, and the book being read
2. Recently watched movies and series
3. Recently read books

Wish lists are not on Home. They are available through the "Want to ..." status filter on the
Books, Movies and Series screens.

Navigation: bottom bar with Home, Books, Movies, Series, Library.

## Detail pages
Opened from any poster or hero card (`/item/:id`). All use a large HD poster header that collapses
into the app bar, with a round back button.
- Status dropdown beside the title. The last menu item is "Remove from Bookmark" (with confirmation).
- Rating shown as a coloured ring (green 7+/10 or 3.5+/5, amber, red) next to year, runtime/pages, age rating.
- Details are fetched when the page opens. If offline, the saved info still shows with a short note.
- "You may also like" row at the bottom: tap an item in the library to open it, or a new one to add it.

**Movie:** tagline, genres, overview, director, cast. Age rating (Australia first, then US).
Recommendations from TMDB.

**Series:** same info plus creators, number of seasons and show status (Ongoing/Ended).
Shows overall progress, then only the latest season as an episode checklist, and a
"More seasons" button that opens a bottom sheet of all seasons with progress (for example 5/10).
Tapping a season opens the season page (`/item/:id/season/:season`) with its episode checklist and
a "Mark season as watched / unwatched" button. Recommendations from TMDB.

**Book:** author, page count, subjects, description, average rating from Open Library.
"Did not complete" opens a sheet with reason chips (plus optional "Other" text) and a
page-stopped-at slider with -10/-1/+1/+10 buttons. Both are optional and can be edited later.
Recommendations: other books by the same author plus top-rated books in one of the book's subjects.

## Data model (Drift tables)
- MediaItems: one table for movie, series and book (type, externalId, title, posterUrl, overview, year, genres, status, rating, author, pageCount, currentPage, dropReason, droppedAtPage, addedAt, lastActivityAt). Unique on (type, externalId). `rating` and `currentPage` are currently unused.
- Episodes: seriesId, seasonNumber, episodeNumber, title, airDate, watched, watchedAt. Unique on (seriesId, seasonNumber, episodeNumber).
- UserLists and ListEntries: custom lists and tags, many-to-many with items

Posters are stored as medium images. Detail pages and the hero swap the URL for a larger version
at display time (TMDB w780, Open Library -L).

## Progress
- [x] Flutter and Android Studio setup
- [x] Project skeleton, Drift database, home screen, list screens
- [x] TMDB and Open Library search and add flow (status picker, episodes fetched for series)
- [x] Empty states with animated illustration (replaces the sample data button)
- [x] go_router, tappable posters and hero, bigger hero, wish lists removed from Home
- [x] Movie detail page (status dropdown, TMDB details, HD poster)
- [x] Book detail page (did-not-complete reason and page, Open Library details)
- [x] Series detail page: latest season checklist, More seasons sheet, season episode page, automatic status rules
- [x] "You may also like" on movie, series and book pages
- [ ] Daily background check for new episodes (workmanager). Also refreshes the saved episode list,
  since episodes are currently only fetched once when a series is added.
- [ ] Lists and tags screen (Library tab)
- [ ] JSON export and import