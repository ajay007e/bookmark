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
- cached_network_image for posters and covers
- dio for API calls
- Planned: go_router (detail screens), workmanager (new-episode checks)
- Data sources: TMDB (movies, series, episodes; free API key kept in lib/config/secrets.dart, gitignored) and Open Library (books)

## Statuses
One enum in code: want, inProgress, done, dropped.
- Movies and series: Want to watch, Watching, Watched
- Books: Want to read, Reading, Read, Did not complete
- Series are tracked per episode (season number, episode number, watched flag and date)
- Did not complete books: optional reason and page stopped at

## Input rules
- Searching titles by typing is fine
- Everything else is selection: status pickers, chips, star-bar rating, fixed lists of reasons
- Typing is allowed only as an option where needed (for example a custom stop reason)
- Details (title, poster, genres, episodes, authors) come from TMDB / Open Library, not manual entry

## Extra features
- Tags, genres and custom lists
- Backup: export everything to a JSON file and import it back

## Home screen
1. Hero carousel with large posters: series being watched, series with a new episode available, and the book being read
2. Recently watched movies and series
3. Recently read books
4. Wish lists for movies, series and books

Navigation: bottom bar with Home, Books, Movies, Series, Library.

## Data model (Drift tables)
- MediaItems: one table for movie, series and book (type, externalId, title, posterUrl, overview, year, genres, status, rating, author, pageCount, currentPage, dropReason, droppedAtPage, addedAt, lastActivityAt). Unique on (type, externalId).
- Episodes: seriesId, seasonNumber, episodeNumber, title, airDate, watched, watchedAt
- UserLists and ListEntries: custom lists and tags, many-to-many with items

## Progress
- [x] Flutter and Android Studio setup
- [x] Project skeleton, Drift database, home screen, list screens
- [x] TMDB and Open Library search and add flow (status picker, episodes fetched for series)
- [x] Empty states with animated illustration (replaces the sample data button)
- [ ] Series detail screen with season and episode checklist
- [ ] Book detail with page progress and did-not-complete reason
- [ ] Daily background check for new episodes
- [ ] Lists and tags screen
- [ ] JSON export and import