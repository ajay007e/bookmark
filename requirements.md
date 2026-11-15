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
- Some code written in chat needed small fixes for the latest package versions (for example `file_picker`).
  The project files are the source of truth: when a change touches a file I may have edited, ask me to paste it.

## Stack

- Flutter (Android only), Dart package name `bookmark`, app display name "Bookmark"
- Drift (SQLite) for the local database, with drift_flutter. Schema version 2 for now (Batch 5 moves it to 3).
  (Drift's SQLite is not visible in Android Studio's Database Inspector, so test through logs or in-app helpers.)
- flutter_riverpod for state
- go_router for navigation (item, preview, genre, list and stats pages)
- convex_bottom_bar for the bottom navigation bar
- cached_network_image for posters and covers
- dio for API calls
- url_launcher for the "Watch now" links
- workmanager for the daily new-episode check
- flutter_local_notifications for new-episode notifications
- shared_preferences (`SharedPreferencesAsync`, safe to use from the app and the worker) for the last-check
  time, the daily check switch, the theme, the accent colour and the streaming region
- share_plus and path_provider for the JSON export (Android share sheet, no storage permission)
- file_picker for choosing a backup file to import (no storage permission)
- package_info_plus for the real app version in About
- Data sources: TMDB (movies, series, episodes, streaming availability; free API key kept in lib/config/secrets.dart, gitignored) and Open Library (books)
- Streaming availability comes from TMDB's watch-provider data, which is supplied by JustWatch.
  Shown for the region chosen in You > Streaming (Australia by default, `watchRegion = 'AU'` in tmdb_client.dart
  is only the default) with the credit line "Streaming data by JustWatch, via TMDB."

## Android setup

- `AndroidManifest.xml` has the app label `Bookmark` (capital B) and the `POST_NOTIFICATIONS` permission
  (needed on Android 13+).
- `android/app/build.gradle.kts` enables core library desugaring
  (`isCoreLibraryDesugaringEnabled = true` and `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`),
  which flutter_local_notifications needs to build.

## Statuses

One enum in code: want, inProgress, done, dropped.

- Movies: Want to watch, Watched. Movies have no Watching status (shown as a disabled option).
- Series: Want to watch, Watching, Watched. The status follows the episodes automatically.
- Books: Want to read, Reading, Read, Did not complete
- Series are tracked per episode (season number, episode number, watched flag and date)
- Did not complete books: optional reason and page stopped at
- Books have no page-progress tracking yet. Only the stop page is recorded, when a book is not completed.
  (Progress tracking is planned in Batch 5.)

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

## Mark flow (tick button, long press, "more" menu, history)

Detail pages for movies, series and books have a round tick button beside the title and a round "⋮"
(more) button in the top bar. There is no status dropdown. The "⋮" button opens the same options as a
long press on the tick. **Unsupported options are shown disabled** (greyed, with a short note), not hidden.

- **Look of the tick:** grey outline = not started, coloured ring with an icon = Watching/Reading, filled =
  done, red with a block icon = Did not complete. The menu sheet shows the status in words.
- **Menu wording:** under "Watched now / Read now" the sheet says "Counts in your watch time" (movies and
  series) or "Counts in your reading stats" (books). Under "Watched earlier / Read earlier" it says
  "Not counted in your watch time" or "Not counted in your reading stats". The word "watch time" is never
  used for books.
- **Not in the library** (opened from a search result or "You may also like"): the page is the normal
  detail page built from a draft item (negative id, nothing saved yet).
  - Movie: tap on the tick = Watched now directly (saves the movie, marks it watched now) with an Undo
    snackbar. The snackbar goes away by itself after 5 seconds and has no close button. Undo deletes the
    movie again (with its history). Long press or "⋮": Want to watch, Watched earlier, Add to list.
  - Book: tap on the tick = add to Want to read. Long press or "⋮": Reading, Read now, Read earlier, Add to list.
  - Series: tap on the tick = add to Want to watch (saved with all its episodes). Long press or "⋮": Add to
    list, Mark aired episodes watched now / earlier (Mark all unwatched and Remove are disabled).
  - Any option saves the item first (as Want), then applies. The page then switches to the saved item
    without reloading, so scroll position and tabs stay.
  - While an unsaved series is being saved, a full-page loading spinner covers the series page
    (`draftSavingProvider`, `lib/ui/draft_saving.dart`). The previous episode list stays on screen until
    the saved list is ready, so the page never flickers or shows an empty list.
- **Movie (saved):**
  - Want: tap = Watched (now). Menu: Watching (disabled, "Movies have no Watching status"), Watched now,
    Watched earlier, Add to list, Remove.
  - Watched: tap = back to Want (asks first, **deletes all history rows** of the movie, so stats drop).
    Menu: Watched again now, Add to list, Remove.
- **Book (saved):**
  - Want: tap = Reading. Reading: tap = Read now. Read: tap = back to Want (asks first, deletes all history).
  - Did not complete: tap = Reading.
  - Menu (Want, Did not complete): Reading, Read now, Read earlier, Add to list, Remove.
    Menu (Reading): Read now, Read earlier, Did not complete, Add to list, Remove.
    Menu (Read): Read again now, Add to list, Remove.
- **Series (saved):** the tick is a disabled status icon (Want / Watching / Watched); the status
  follows the episodes. The "⋮" menu holds: Add to list, Mark aired episodes watched now, Mark aired
  episodes watched earlier, Mark all episodes unwatched (asks first, disabled when nothing is marked),
  Remove (asks first). The two "mark aired" options are disabled when nothing has aired or you are up to date.
- **Episodes:** tap the tick = Watched now. Long press = choose Watched now or Watched earlier (only on an
  aired, unticked episode). Tapping a ticked episode unticks it.
- **Season button ("Mark season as watched"):** tap = Watched now. Long press = choose Watched now or
  Watched earlier. When every aired episode is ticked it becomes "Mark season as unwatched" (asks first).
- **Unsaved series:** the Episodes tab shows episodes fetched from TMDB (`draftEpisodesProvider`), with
  the same UI. The first mark (episode, season or menu) saves the series as Want with all its episodes,
  then applies the mark.
- **Watched now** counts in the watch time. **Watched earlier** is saved but not counted.
- **Episodes marked via "Mark earlier episodes too?"** are always saved as watched earlier.
- **History (WatchLogs):** every mark writes a row (item, episode for series, time, counted flag,
  minutes). Rewatching a movie or book adds another row. "Back to Want" deletes every row of the item.
  "Mark all episodes unwatched" unticks all episodes and removes their rows. Items saved with
  "Watched earlier" or "Read earlier" are saved as earlier. Items marked before the history feature have no rows.
- Runtime is stored when known (movies, series episode length, each episode) so watch time can be
  calculated.
- **Snackbars** with an action (such as Undo) must always close by themselves (`persist: false`, 5 seconds).
  No close button.
- Code: `lib/ui/watch_actions.dart` (menus per type and state, actions, tap cycle),
  `lib/ui/series_actions.dart` (episode marking, now or earlier, unsaved series),
  `lib/ui/draft_item.dart` and `lib/ui/draft_series.dart` (unsaved items and episodes),
  `lib/ui/draft_saving.dart` (the "saving an unsaved series" flag),
  `lib/data/mark_queries.dart` (back to Want), `lib/ui/widgets/watch_tick.dart`,
  `lib/ui/widgets/item_menu_button.dart`, `lib/ui/widgets/season_button.dart`, `lib/ui/widgets/episode_card.dart`.

## Input rules

- Searching titles by typing is fine
- Everything else is selection: ticks, menus, chips, sliders, fixed lists of reasons, colour circles
- Typing is allowed only as an option where needed (for example a custom stop reason, a list name, or a
  page count for a book that has none)
- Details (title, poster, genres, episodes, authors, ratings, cast) come from TMDB / Open Library, not manual entry
- No personal rating or review. The `rating` column exists in the database but is unused.

## Navigation and look

Bottom bar (convex_bottom_bar package, `react` style, theme colours, selected icon lifted into the bump
at normal size, icons only) with three tabs: **Home, Contents, You**. `HomeShell` keeps all three alive
with an `IndexedStack`. Detail pages are pushed on top of the shell. The bar is in
`lib/ui/widgets/app_nav_bar.dart`; `navBarClearance()` is a small gap because Scaffold already sizes the body.

Top bar (`PremiumAppBar`): small letter-spaced eyebrow (today's date), large gradient title, round glass
action buttons (`AppBarAction`).

Routes: `/` (shell), `/item/:id` (saved item), `/preview` (an item not in the library; the `SearchResult`
is passed as `extra`), `/genre?name=`, `/list/:id`, `/stats?period=`.

## Search

Opened with "+" (Contents) or the search button (Home). Movies / Series / Books selector and a search box.
Tapping a result opens the detail page: the saved page (`/item/:id`) if it is already in the library
(shown with an "Added" chip), otherwise `/preview`. There is no status sheet. Adding happens with the tick.

## Contents tab

Pill segments (`PillSegments`): **Movies, Series, Books, Lists**, swipeable. The "+" in the top bar opens
search with the current type preselected (hidden on Lists). Movies, Series and Books reuse
`MediaListScreen` (status filter chips, poster grid). Each segment keeps its filter and scroll position.

**Lists segment**

- Browse by genre: one sideways row with the 8 most common genres and counts, then an "All genres (N)"
  chip that opens a scrollable sheet with every genre. Tapping a genre opens `/genre?name=` (all
  movies, series and books with that genre, with type filter chips).
- Tags are genres only for now.
- My lists: cards with a poster collage, name and item count. The **"New list" card is always the first
  card**, before the existing lists.
  A list page (`/list/:id`) shows a poster grid; menu has Rename and Delete; long-press an item to
  remove it from the list (with Undo). Deleting a list never deletes its items. List names are unique
  (ignoring case). Items are shown A to Z (ListEntries has no date column).
  "Add to list" is in the tick's long-press menu and the "⋮" menu.

## You tab

One scrolling page: stats on top, then grouped settings.

- **Stats card:** shows Week by default (watch time, movies, episodes, books). A small pill in the card's
  top right shows the period (for example "Week ▾") and opens a bottom sheet ("Show stats for") with
  Week, Month, Year and All time (icon, short description, tick on the chosen one). Tapping the card opens
  `/stats?period=` with the chosen period. There are no period pills on the card and no "Detailed stats" button.
- **Appearance:** theme (System / Light / Dark) and accent colour (16 colours in one sideways row).
  Both are saved with SharedPreferencesAsync and applied to the whole app.
- **New episodes:** "Daily check" switch, on by default, saved as `dailyCheckEnabled`
  (`lib/settings/daily_check_provider.dart`). Turning it off cancels the workmanager task, turning it on
  schedules it again. The worker also checks the setting before it runs. Tapping the whole row toggles it.
- **Streaming:** "Region" row showing the country and code (for example "Australia (AU)"). Tapping it opens a
  scrollable sheet of 46 countries with a tick on the current one (`lib/ui/widgets/region_sheet.dart`).
  The choice is saved as `watchRegion` in SharedPreferencesAsync (`lib/settings/region_provider.dart`,
  default AU). It decides the "Watch now" options, the age rating and the release date: the chosen region
  is tried first, then the US. Open detail pages reload when it changes. Another country is added with one
  line in the `regions` list.
- **Backup and data:** Export to JSON and Import from JSON, both working (see Backup below).
- **About:** the real version, for example "1.0.0 (1)", read from the `version:` line in pubspec.yaml with
  package_info_plus (`lib/settings/app_info_provider.dart`), and a "Credits and data sources" sheet
  (TMDB notice, JustWatch line, Open Library).

## Stats

- Summary card on the You tab and a detailed page at `/stats?period=`.
- Views: All, Movies, Series, Books. Periods: Week (from Monday), Month, Year, All time.
- On the detailed page the four period chips share the full width equally (no empty space on the right).
- Each view has tiles, an activity chart (days for Week and Month, months for Year, years for All time)
  and top genres (ranked by number of different titles). All also shows movies vs series split.
  Books show book counts, pages read, average pages and most read author.
- Only WatchLogs rows with counted = true are counted. A rewatch counts again. Books are counted, not
  timed. "Did not complete" is an all-time number.
- Code: `lib/data/stats_queries.dart` (query), `lib/stats/stats_models.dart` (periods, filters and all
  the numbers), `lib/stats/stats_provider.dart` (providers), `lib/ui/stats_screen.dart`,
  `lib/ui/widgets/stats_card.dart`. `StatsPeriod` is defined only in `stats_models.dart`.
- Planned (Batch 7): a "Window" option. Off (default): Week, Month and Year are the current calendar week,
  month and year, as today. On: they become rolling ranges ending today: Last 7 days, one calendar month
  back from today (28, 29, 30 or 31 days), and Last 12 months. All time is the same. Charts stay by day
  for 7 days and a month, and by month for 12 months. The switch sits in the period sheet on the You card
  and on the Stats page, is saved in SharedPreferencesAsync, and both screens share the choice.
- Planned (Batch 5): reading stats (see Reading tracking below).

## Reading tracking (planned, Batch 5, schema 3)

- Per book progress unit: Pages (default when a page count is known) or Percent (default when not; the
  Kindle mode). Locations are not supported. Switching unit converts using the page count. Optional: type
  a page count for a book that has none (the only typing); once set, percent entries convert to pages.
- Book page: Progress card (page X of Y, %, bar, Update button) while Reading. Update sheet: slider with
  -10/-1/+1/+10 and optional time spent chips (None, 15, 30, 45, 60, 90). Moving backwards corrects the page
  and logs nothing. Reaching the last page or 100% asks "Finished? Mark as read now" (never automatic).
- "Update progress" in the long-press menu for Want and Reading books. Saving on a Want book sets it to Reading.
- Hero card for a Reading book: bar, "Page X/Y" (or "X%"), an Update progress button beside the tick.
- Rules: Read now credits the remaining pages to today. Read earlier credits nothing. Read again now credits
  the full page count. Did not complete: stop page prefilled from progress, pages stay in stats. Back to
  Want: deletes the reading log and resets progress.
- New table ReadingLogs (itemId, readAt, fromPage, toPage, pages, minutes), new column for the progress
  unit on MediaItems, schema 3 migration. Reuse `currentPage` for the current value.
- ReadingLogs and the progress unit are added to the JSON export and import in this batch. A backup made
  before it still imports (no reading history).
- Stats, Books view: pages read, reading days, average pages per reading day, current and longest streak,
  reading time (only if logged), and a pages chart. The You card gets a Pages read tile. Books with no page
  count count for reading days, streaks, time and finished, not for pages (small footnote on the stats
  screen). Never say "watch time" for books. No reading goals and no estimated reading time for now.

## Backup (You > Backup and data)

Code: `lib/data/export_queries.dart`, `lib/data/backup_service.dart` (export),
`lib/data/import_queries.dart`, `lib/ui/import_flow.dart` (import).

- **Export:** reads every table of the current schema (MediaItems, Episodes, WatchLogs, UserLists,
  ListEntries) and writes one JSON file named `bookmark-backup-YYYY-MM-DD.json` to the temporary folder,
  then opens the Android share sheet (save to Files or Drive, or send it to yourself).
  The file has `app: "bookmark"`, `format` (1), `schemaVersion`, `exportedAt` and a `counts` block.
  Enums are written as names (`movie`, `inProgress`), dates as UTC text, and ids are kept as they are.
- **Import:** pick the file with the system file chooser. The app checks it (a Bookmark backup, a format it
  understands, not from a newer version) and changes nothing if it is not valid. Older backups with a
  missing table or field still import (missing means empty or default, unknown fields are ignored).
  All writes happen in one transaction, so an import either fully succeeds or changes nothing. A report
  is shown at the end ("Import done: 30 added, 12 merged, ...").
  - Ids in the file are never trusted: a map from backup id to the real id on the phone is used for
    episodes, history and list entries.
  - Empty library: everything is imported after one confirmation.
  - Items are matched by type + external id (TMDB id or Open Library key).
  - Item only in the backup: added with its episodes and history. Item only on the phone: untouched.
  - Item on both with the same progress (status, stop details, ticked episodes, history): skipped.
  - Item on both with different progress is a **conflict**. One sheet lists the titles with the reason
    (for example "Phone: Watching, backup: Watched") and the user picks one choice for all of them:
    - **Merge both (recommended):** ticked episodes are the union, history rows are the union (identical rows
      skipped), the status and stop reason come from the side with the later activity, missing details are
      filled from the other side, and a series status is recalculated from the merged episodes.
    - **Keep my phone's version:** conflicting items stay as they are.
    - **Use the backup's version:** conflicting items take the backup's status, ticks and history.
  - Lists are joined by name (ignoring case) and their entries are combined. They are never a conflict.
  - Importing the same file twice changes nothing the second time.

## Background check and notifications

Code lives in `lib/background/`.

- **Schedule:** a WorkManager periodic task (`bookmark.episodeCheck`) runs about every 24 hours
  (first run after 1 hour) when the phone has a network connection. It is registered on every app
  launch with the `keep` policy, so it is never duplicated, unless the daily check switch is off, in which
  case the task is cancelled. Android decides the exact time.
  On some phones (OnePlus) background activity may need to be allowed in Apps → Bookmark → Battery.
- **Switch:** `dailyCheckEnabled` in SharedPreferencesAsync (on by default). `setDailyCheck(bool)` in
  `background_worker.dart` saves it and schedules or cancels the task. The worker skips the run when it is off.
- **Worker isolate:** the worker runs in its own isolate. It cannot use Riverpod or the app's open
  database, so it opens its own `AppDatabase()` connection to the same file and closes it when done.
  Because of that, open screens may not refresh until reopened. The region does not affect the worker.
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
  dropped) and has unticked episodes that have aired since the last check. An episode is announced only
  when its air date has arrived: local calendar days are compared (TMDB gives a date only), the air date
  must be today or earlier and later than the day of the last check. An episode with no air date never
  notifies. An episode aired today is announced at the next daily check that day. The first run only
  records the time and sends nothing. Text: "S2 E5 · Title is out" for one episode, "N new episodes are out"
  for several. The notification id is the series id, so a newer one replaces the older one.
- **Image:** a wide, rectangular backdrop (`TmdbClient.seriesBackdrop`, TMDB w780) in Android's
  big picture style, shown when the notification is expanded. Falls back to the saved poster, then
  to text only. Image download failures never block the notification.
- **Tap:** the payload is the series' database id. Tapping opens `/item/:id` on top of Home,
  both when the app is running (tap handler passed to `initNotifications`) and when the app was
  closed (launch payload checked after the first frame).
- **Permission:** the Android 13+ notification permission is requested from the app on launch,
  never from the worker. Each isolate calls `initNotifications()` itself.
- **Testing:** use the temporary `debugRewindLastCheck()` (sets the last check to 30 days ago) and
  `runEpisodeCheckNow()` (runs the task once), both in `background_worker.dart`, before `runApp`, then
  remove the calls.

## Home screen

1. Hero carousel with large posters (about 60% of the screen height). It only shows things you
   can act on, each with the same round tick used on the detail pages. Order: active items first
   (by last activity), then Want to watch movies.
   - **Series:** only a series (Watching or Watched) that has an aired, unticked episode. The card
     shows "Up next", or "New episode available" when an unticked aired episode aired after your
     last activity on the series. Under the title is the next episode (S2 E5 · title) with a tick
     that marks it watched now. The next episode is the first aired, unticked episode after the
     furthest one ticked, or the earliest unticked aired one if none follows it. Ticking uses the
     usual "Mark earlier episodes too?" prompt.
   - **Book being read:** a tick at the end of the title marks it as read now.
   - **Movie in Watching:** only possible with older data (movies no longer have a Watching option).
     A tick at the end of the title marks it as watched.
   - **Movie in Want to watch:** up to 10, newest added first, subtitle "Want to watch", shown after all
     the active items. The tick marks it watched now (`lib/data/hero_queries.dart`).
   - A series you have watched up to the last aired episode is not shown, even if it is still
     running. It comes back when new episodes are saved for it (the daily background check does
     that automatically). Tapping the rest of a card opens the item's page.
2. Recently watched movies and series
3. Recently read books

Wish lists for books and series are not on Home. They are available through the "Want to ..." status
filter on the Movies, Series and Books segments of the Contents tab. A search button sits in the top bar.

## Detail pages

Opened from any poster or hero card, a search result, a "You may also like" item, or a new-episode
notification (`/item/:id` or `/preview`). All use a large HD poster header that collapses
into the app bar, with a round back button and a round "⋮" button. The title row is "Name (year)"
with the tick button on the right; the button never makes the row taller than the title.
The same views are used for saved items and for items not in the library (draft items, see Mark flow).

- Rating shown as a coloured ring (green 7+/10 or 3.5+/5, amber, red).
- Details are fetched when the page opens, for the region chosen in You > Streaming. If offline, the saved
  info still shows with a short note.
- Sections are separated by thin lines (Cast, Similar).
- "You may also like" row: tap any item to open its page (the saved page for items in the library,
  marked with a small tick; otherwise a preview page).
- Note: the "Watch now" section (`WatchNowSection`) is currently commented out in `movie_detail_view.dart`
  and `series_detail_view.dart`. Uncomment `WatchNowSection(options: loaded?.watch)` to show it.

**Movie** (top to bottom): title (year) + tick; rating ring | line 1: age rating · duration, line 2:
release date (country) · original language · status; categories; Watch now (Stream, Free, Rent,
Buy with logos in the chosen region; a logo opens TMDB's watch page); tagline; overview; Director | Writer;
Cast; Similar. Age rating: chosen region first, then US. Release date: cinema release in the chosen region,
then US, then the general date.

**Series** has two tabs.

- **Details tab:** title (year) + status icon; rating ring | line 1: age rating (chosen region first, then US),
  line 2: original language · status (Ongoing/Ended); categories; Watch now; tagline; overview; Creator;
  Cast; Similar.
- **Episodes tab:** a plain app bar with the tabs, then a row of season cards (poster, Season n,
  watched/total, rating · year · n episodes, overview or "Aired x of y episodes", progress bar)
  that scrolls sideways and stays pinned at the top. Below it the episodes of the selected season
  scroll on their own. The tab opens on the season of the last watched episode (the furthest
  ticked one) with that episode at the top of the list; with nothing ticked it opens on season 1.
  Tapping a season card shows that season from episode 1. Each episode shows image, n. title,
  rating · air date · runtime, description (tap to expand) and its own tick (tap = watched now,
  long press = now or earlier). "Mark season as watched / unwatched" sits above the list (tap = now,
  long press = now or earlier). Works the same for a series that is not in the library yet.

**Book** (top to bottom): title (year) + tick; by Author; rating ring | pages · language ·
publisher (from the most prominent English edition); categories; "Did not complete" card (reason,
page stopped at, edit) when it applies; About this book; Similar.
"Did not complete" opens a sheet with reason chips (plus optional "Other" text) and a
page-stopped-at slider with -10/-1/+1/+10 buttons. Both are optional and can be edited later.
Recommendations: other books by the same author plus top-rated books in one of the book's subjects.

## Data model (Drift tables, schema version 2)

- MediaItems: one table for movie, series and book (type, externalId, title, posterUrl, overview, year, genres, status, rating, runtime, ongoing, author, pageCount, currentPage, dropReason, droppedAtPage, addedAt, lastActivityAt). Unique on (type, externalId). `rating` and `currentPage` are unused until Batch 5. `runtime` is minutes (movie length or typical episode length). `ongoing` is null until known. `genres` is a comma separated text.
- Episodes: seriesId, seasonNumber, episodeNumber, title, airDate, runtime, watched, watchedAt. Unique on (seriesId, seasonNumber, episodeNumber).
- WatchLogs: itemId, episodeId (null for movies and books), watchedAt, counted (true = watched now, false = watched earlier), minutes.
- UserLists (id, unique name) and ListEntries (listId, itemId, primary key on both, cascade delete): custom lists, many-to-many with items.
- Draft items and draft episodes (not in the database) use negative ids.
- Batch 5 adds ReadingLogs and a progress unit column (schema 3).

Posters are stored as medium images. Detail pages and the hero swap the URL for a larger version
at display time (TMDB w780, Open Library -L).

## Release

Before version 1 (end of Batch 7): measure the release APK size
(`flutter build apk --release --split-per-abi`, and `flutter build apk --analyze-size --target-platform android-arm64`),
check that code and resource shrinking are on in `android/app/build.gradle.kts`, trim anything large,
then release version 1. (A debug build from `flutter run` is always much bigger than a release build.)

## Progress

- [x] Flutter and Android Studio setup
- [x] Project skeleton, Drift database, home screen, list screens
- [x] TMDB and Open Library search and add flow
- [x] Empty states with animated illustration (replaces the sample data button)
- [x] go_router, tappable posters and hero, bigger hero, wish lists removed from Home
- [x] Movie, book and series detail pages
- [x] "You may also like" on movie, series and book pages
- [x] Tick button with long-press options, watch history (WatchLogs), database schema 2
- [x] Series status rules (running series stay Watching)
- [x] Redesigned detail layouts, Watch now
- [x] Series Details and Episodes tabs (pinned season cards, last watched episode at the top)
- [x] Home hero as a to-do list: next episode with tick, book and movie ticks, caught-up series hidden
- [x] Daily background check for new episodes (workmanager): refreshes saved episodes, genres, runtime and ongoing flag
- [x] New-episode notifications with a wide backdrop image, tap opens the series page
- [x] Navigation: three tabs (Home, Contents, You), Contents segments, new top bar, convex bottom bar
- [x] You tab with settings sections, theme switcher and 16 accent colours (saved)
- [x] Genre browsing in Contents > Lists (top 8 row, all genres sheet, genre page)
- [x] Stats card on the You tab
- [x] Detailed stats page: All, Movies, Series, Books
- [x] Custom lists: create, rename, delete, list page, "Add to list"
- [x] Search results and "You may also like" open the detail page (draft items, `/preview`), tick adds to Want
- [x] Real episodes shown for a series that is not in the library yet
- [x] Mark flow rewrite: tap cycle, per-state menus with disabled options, back to Want with history delete,
      episode and season long press, "⋮" menu
- [x] Batch 1: app label "Bookmark", reading wording on the book sheet, "New list" card first
- [x] Batch 2: notify only once the air date has arrived, daily check switch wired to workmanager
- [x] Batch 3: stats card with period pill and sheet (default Week), full-width period chips on the Stats page,
      unsaved movie tick = Watched now with auto-dismissing Undo, series flicker fix (loading overlay),
      Want to watch movies in the Home hero
- [x] Batch 4: JSON export (share sheet)
- [x] JSON import with conflict handling (merge both, keep phone, use backup)
- [x] Batch 6: region picker (46 countries, saved, drives Watch now, age rating and release date) and real
      app version in About (package_info_plus)
- [ ] Batch 5: reading tracking (schema 3, ReadingLogs, progress unit), book stats, ReadingLogs in export and import
- [ ] Batch 7: rolling "Window" stats (Last 7 days, Last month, Last 12 months), then app size check, then release version 1
- [ ] Background check polish (optional, when the library grows): short pause between series for
      TMDB rate limits, skip long-ended shows, show "last checked" time (needs a schema migration)
- [ ] Later, if wanted: remember the last Contents segment after closing the app, newest-first order in
      lists (needs a schema change), filter noisy Open Library subjects in genre chips, reading goals
