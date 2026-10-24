# Bookmark: requirements

## Overview
Bookmark is a personal Android app for tracking books, movies and series.
No login or accounts. All data lives in a local database on the phone.

## Environment
- Ubuntu, Flutter installed with snap, Android Studio as the editor (not VS Code)
- I am new to Flutter and Dart: explain commands and new concepts briefly
- Give complete files with the file path above each one, and tell me how to run and check each step
- Build in small steps
- At the end of each reply, list completed and pending tasks. A task stays pending until I confirm it works.

## Stack
- Flutter (Android only), Dart package name `bookmark`, app display name "Bookmark"
- Drift (SQLite) for the local database, with drift_flutter. Schema version 2 (no change for lists or stats).
  (Drift's SQLite is not visible in Android Studio's Database Inspector, so test through logs or in-app helpers.)
- flutter_riverpod for state
- go_router for navigation (item, genre, list and stats pages)
- convex_bottom_bar for the bottom navigation bar
- cached_network_image for posters and covers
- dio for API calls
- url_launcher for the "Watch now" links
- workmanager for the daily new-episode check
- flutter_local_notifications for new-episode notifications
- shared_preferences (`SharedPreferencesAsync`, safe to use from the app and the worker) for the last-check
  time, the theme and the accent colour
- Data sources: TMDB (movies, series, episodes, streaming availability; free API key kept in lib/config/secrets.dart, gitignored) and Open Library (books)
- Streaming availability comes from TMDB's watch-provider data, which is supplied by JustWatch.
  Shown for Australia only (`watchRegion = 'AU'` in tmdb_client.dart) with the credit line
  "Streaming data by JustWatch, via TMDB."

## Android setup
- `AndroidManifest.xml` has the `POST_NOTIFICATIONS` permission (needed on Android 13+).
- `android/app/build.gradle.kts` enables core library desugaring
  (`isCoreLibraryDesugaringEnabled = true` and `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`),
  which flutter_local_notifications needs to build.

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
  known yet it is treated as running. The status is saved the first time the series page loads
  and is refreshed by the daily background check.
- A series that has ended becomes Watched when every aired episode is ticked.
- A Watched series that gets new aired episodes (from the background check) goes back to Watching.
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
    - Movie: Add to wishlist, Watched now (Watched again now), Watched earlier, Mark as unwatched, Add to list, Remove.
    - Series: Add to wishlist, Watched now, Watched earlier, Mark as unwatched, Add to list, Remove.
      For a running series the two watched options mark the aired episodes.
    - Book: Want to read, Reading, Read now (Read again now), Read earlier, Did not complete,
      Mark as unread, Add to list, Remove. Movies have no "Watching" option.
- **Watched now** counts in the watch time. **Watched earlier** is saved but not counted.
- **Episodes** only have watched / not watched, with their own tick (no long press). A ticked
  episode counts as watched now.
- **History (WatchLogs):** every mark writes a row (item, episode for series, time, counted flag,
  minutes). Rewatching a movie or book adds another row. "Mark as unwatched" removes the latest
  row of a movie or book (the status goes back to Want only when no rows are left). For a series it
  unticks all episodes and removes their rows. Things added through the search sheet as
  Watched/Read are saved as earlier. Items marked before this feature have no rows.
- Runtime is stored when known (movies, series episode length, each episode) so watch time can be
  calculated.

## Input rules
- Searching titles by typing is fine
- Everything else is selection: ticks, menus, chips, sliders, fixed lists of reasons, colour circles
- Typing is allowed only as an option where needed (for example a custom stop reason, or a list name)
- Details (title, poster, genres, episodes, authors, ratings, cast) come from TMDB / Open Library, not manual entry
- No personal rating or review. The `rating` column exists in the database but is unused.

## Navigation and look
Bottom bar (convex_bottom_bar package, `react` style, theme colours, selected icon lifted into the bump
at normal size, icons only) with three tabs: **Home, Contents, You**. `HomeShell` keeps all three alive
with an `IndexedStack`. Detail pages are pushed on top of the shell. The bar is in
`lib/ui/widgets/app_nav_bar.dart`; `navBarClearance()` is a small gap because Scaffold already sizes the body.

Top bar (`PremiumAppBar`): small letter-spaced eyebrow (today's date), large gradient title, round glass
action buttons (`AppBarAction`).

Routes: `/` (shell), `/item/:id`, `/genre?name=`, `/list/:id`, `/stats?period=`.

## Contents tab
Pill segments (`PillSegments`): **Movies, Series, Books, Lists**, swipeable. The "+" in the top bar opens
search with the current type preselected (hidden on Lists). Movies, Series and Books reuse
`MediaListScreen` (status filter chips, poster grid). Each segment keeps its filter and scroll position.

**Lists segment**
- Browse by genre: one sideways row with the 8 most common genres and counts, then an "All genres (N)"
  chip that opens a scrollable sheet with every genre. Tapping a genre opens `/genre?name=` (all
  movies, series and books with that genre, with type filter chips).
- Tags are genres only for now. Custom lists are a separate feature.
- My lists (waiting for test): cards with a poster collage, name and item count, plus a "New list" card.
  A list page (`/list/:id`) shows a poster grid; menu has Rename and Delete; long-press an item to
  remove it from the list (with Undo). Deleting a list never deletes its items. List names are unique
  (ignoring case). Items are shown A to Z (ListEntries has no date column).

## You tab
One scrolling page: stats on top, then grouped settings.
- **Stats card:** Week / Month / Year / All time selector, watch time, movies, episodes and books, and a
  "Detailed stats" button.
- **Appearance:** theme (System / Light / Dark) and accent colour (16 colours in one sideways row).
  Both are saved with SharedPreferencesAsync and applied to the whole app.
- **New episodes:** daily check switch (placeholder, "Soon"). Will control the workmanager task.
- **Streaming:** region (placeholder, "Soon"). Fixed to Australia for now.
- **Backup and data:** Export to JSON and Import from JSON (placeholders, "Soon").
- **About:** version, and a "Credits and data sources" sheet (TMDB notice, JustWatch line, Open Library).

## Stats
- Summary card on the You tab and a detailed page at `/stats?period=`.
- Views: All, Movies, Series, Books. Periods: Week (from Monday), Month, Year, All time.
- Each view has tiles, an activity chart (days for Week and Month, months for Year, years for All time)
  and top genres (ranked by number of different titles). All also shows movies vs series split.
  Books show book counts, pages read, average pages and most read author.
- Only WatchLogs rows with counted = true are counted. A rewatch counts again. Books are counted, not
  timed. "Did not complete" is an all-time number.
- Code: `lib/data/stats_queries.dart` (query), `lib/stats/stats_models.dart` (periods, filters and all
  the numbers), `lib/stats/stats_provider.dart` (providers), `lib/ui/stats_screen.dart`.
  `StatsPeriod` is defined only in `stats_models.dart`.

## Extra features
- Genres (browse and filter) and custom lists, see Contents tab
- Backup: export everything to a JSON file and import it back (including the watch history). Planned,
  lives in Settings, Backup and data. Import should ask before replacing or merging.

## Background check and notifications
Code lives in `lib/background/`.
- **Schedule:** a WorkManager periodic task (`bookmark.episodeCheck`) runs about every 24 hours
  (first run after 1 hour) when the phone has a network connection. It is registered on every app
  launch with the `keep` policy, so it is never duplicated. Android decides the exact time.
  On some phones (OnePlus) background activity may need to be allowed in Apps → Bookmark → Battery.
- **Worker isolate:** the worker runs in its own isolate. It cannot use Riverpod or the app's open
  database, so it opens its own `AppDatabase()` connection to the same file and closes it when done.
  Because of that, open screens may not refresh until reopened.
- **Refresh (`EpisodeRefresher`):** for every series in the library it fetches TMDB details
  (`seriesDetails`) and applies them with `AppDatabase.applySeriesRefresh` in one transaction:
    - new episodes are inserted
    - existing episodes get a new title, air date or runtime (a missing value never erases saved data)
    - genres, runtime and the ongoing flag are updated
    - the series status is recalculated
    - `watched`, `watchedAt` and `lastActivityAt` are never changed (so the hero can still show
      "New episode available")
- **Failures:** each series has its own try/catch, so one failure does not stop the others.
  The task asks Android to retry only when every series failed.
- **Last check:** the time of the last successful check is saved as `lastEpisodeCheck`
  (milliseconds) with `SharedPreferencesAsync`. It only moves forward when no series failed, so a
  network error never makes an episode be missed (a partial failure can repeat a notification).
- **Notifications:** one notification per series that is Watching or Watched (not wishlist or
  dropped) and has unticked episodes that aired after the last check. The first run only records
  the time and sends nothing. Text: "S2 E5 · Title is out" for one episode, "N new episodes are out"
  for several. The notification id is the series id, so a newer one replaces the older one.
- **Image:** a wide, rectangular backdrop (`TmdbClient.seriesBackdrop`, TMDB w780) in Android's
  big picture style, shown when the notification is expanded. Falls back to the saved poster, then
  to text only. Image download failures never block the notification.
- **Tap:** the payload is the series' database id. Tapping opens `/item/:id` on top of Home,
  both when the app is running (tap handler passed to `initNotifications`) and when the app was
  closed (launch payload checked after the first frame).
- **Permission:** the Android 13+ notification permission is requested from the app on launch,
  never from the worker. Each isolate calls `initNotifications()` itself.
- **Testing:** use a temporary `debugRewindLastCheck()` (sets the last check to 30 days ago) and
  `runEpisodeCheckNow()` (runs the task once) before `runApp`, then remove them.

## Home screen
1. Hero carousel with large posters (about 60% of the screen height). It only shows things you
   can act on, each with the same round tick used on the detail pages:
    - **Series:** only a series (Watching or Watched) that has an aired, unticked episode. The card
      shows "Up next", or "New episode available" when an unticked aired episode aired after your
      last activity on the series. Under the title is the next episode (S2 E5 · title) with a tick
      that marks it watched. The next episode is the first aired, unticked episode after the
      furthest one ticked, or the earliest unticked aired one if none follows it. Ticking uses the
      usual "Mark earlier episodes too?" prompt.
    - **Book being read:** a tick at the end of the title marks it as read.
    - **Movie set to Watching** (only possible by adding it as Watching from the search sheet): a
      tick at the end of the title marks it as watched.
      A series you have watched up to the last aired episode is not shown, even if it is still
      running. It comes back when new episodes are saved for it (the daily background check does
      that automatically). Tapping the rest of a card opens the item's page.
2. Recently watched movies and series
3. Recently read books

Wish lists are not on Home. They are available through the "Want to ..." status filter on the
Movies, Series and Books segments of the Contents tab. A search button sits in the top bar.

## Detail pages
Opened from any poster or hero card, or a new-episode notification (`/item/:id`). All use a large HD poster header that collapses
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
- MediaItems: one table for movie, series and book (type, externalId, title, posterUrl, overview, year, genres, status, rating, runtime, ongoing, author, pageCount, currentPage, dropReason, droppedAtPage, addedAt, lastActivityAt). Unique on (type, externalId). `rating` and `currentPage` are unused. `runtime` is minutes (movie length or typical episode length). `ongoing` is null until known. `genres` is a comma separated text.
- Episodes: seriesId, seasonNumber, episodeNumber, title, airDate, runtime, watched, watchedAt. Unique on (seriesId, seasonNumber, episodeNumber).
- WatchLogs: itemId, episodeId (null for movies and books), watchedAt, counted (true = watched now, false = watched earlier), minutes.
- UserLists (id, unique name) and ListEntries (listId, itemId, primary key on both, cascade delete): custom lists, many-to-many with items.

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
- [x] Home hero as a to-do list: next episode with tick, book and movie ticks, caught-up series hidden
- [x] Daily background check for new episodes (workmanager): refreshes saved episodes, genres, runtime and ongoing flag
- [x] New-episode notifications with a wide backdrop image, tap opens the series page
- [x] Navigation: three tabs (Home, Contents, You), Contents segments, new top bar, convex bottom bar
- [x] You tab with settings sections, theme switcher and 16 accent colours (saved)
- [x] Genre browsing in Contents > Lists (top 8 row, all genres sheet, genre page)
- [ ] Stats card on the You tab (built, waiting for test)
- [ ] Detailed stats page: All, Movies, Series, Books (built, waiting for test)
- [ ] Custom lists: create, rename, delete, list page, "Add to list" in the long-press menu (built, waiting for test; first the missing list providers and list methods must compile)
- [ ] Settings: daily check switch wired to workmanager (needs `lib/background/background_worker.dart`)
- [ ] Settings: region picker (replaces the fixed `watchRegion`)
- [ ] JSON export and import (include the watch history), in Settings > Backup and data
- [ ] Real app version in About (package_info_plus)
- [ ] Background check polish (optional, when the library grows): short pause between series for
  TMDB rate limits, skip long-ended shows, show "last checked" time (needs a schema 3 migration)
- [ ] Later, if wanted: remember the last Contents segment after closing the app, newest-first order in
  lists (needs schema 3), filter noisy Open Library subjects in genre chips