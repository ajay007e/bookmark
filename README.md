<p align="center">
  <img src="assets/icon/app_icon.png" alt="Bookmark app icon" width="120">
</p>

<h1 align="center">Bookmark</h1>

<p align="center">
  A personal Android app to track the books you read, the movies you watch and the series you follow, episode by episode.<br>
  No account, no cloud. Everything is stored on your phone.
</p>

## Features

- **One place for books, movies and series.** Search by title, pick a result and choose a status. Posters, genres, descriptions, cast and episode lists are filled in for you.
- **Statuses that fit each type.**
  - Movies and series: Want to watch, Watching, Watched
  - Books: Want to read, Reading, Read, Did not complete (with an optional reason and the page where you stopped)
- **Episode-level tracking for series.** Tick episodes season by season. The series status follows along automatically, and a finished series shows "New episode available" when a new episode airs.
- **Home screen built around what you are doing now.** A large hero carousel shows the series you are watching and the book you are reading, followed by what you recently watched and read.
- **Detail pages.** Large poster, ratings from TMDB and Open Library, runtime or page count, age rating, cast and crew, and a "You may also like" row.
- **Works offline.** Your library is a local SQLite database. Details are fetched when a page opens, and saved info still shows without a connection.
- **Light and dark themes** that follow the system setting.

## Tech stack

| Area                  | Choice                                                     |
| --------------------- | ---------------------------------------------------------- |
| App                   | Flutter (Android)                                          |
| Local database        | [Drift](https://drift.simonbinder.eu/) (SQLite)            |
| State management      | [Riverpod](https://riverpod.dev/)                          |
| Navigation            | go_router                                                  |
| Networking            | dio                                                        |
| Images                | cached_network_image                                       |
| Movie and series data | [TMDB API](https://www.themoviedb.org/documentation/api)   |
| Book data             | [Open Library API](https://openlibrary.org/developers/api) |

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel) with the Android toolchain set up. `flutter doctor` should show a green tick for Android.
- Android Studio (or any editor) and an Android phone or emulator.
- A free TMDB API key: create an account at [themoviedb.org](https://www.themoviedb.org/), then go to **Settings → API** and copy the **API Key (v3 auth)**. Books work without a key.

### Run the app

```bash
git clone <your-repo-url> bookmark
cd bookmark
flutter pub get

# Add your TMDB key (this file is gitignored)
cp lib/config/secrets.example.dart lib/config/secrets.dart
# then open lib/config/secrets.dart and replace YOUR_TMDB_API_KEY

flutter run
```

The generated Drift file (`lib/data/app_database.g.dart`) is committed, so the app builds without extra steps. If you change the tables in `lib/data/tables.dart`, regenerate it:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Build a release APK

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. Release builds need the internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### App icon

The icon images live in `assets/icon/`. To regenerate the Android launcher icons after changing them:

```bash
dart run flutter_launcher_icons
```

## Project structure

```
lib/
  api/      TMDB and Open Library clients
  config/   API key file (secrets.dart is gitignored, secrets.example.dart is the template)
  data/     Drift tables, queries and repositories
  ui/       Screens and shared widgets
assets/
  icon/     App icon source images
```

## Privacy

Bookmark has no login and no analytics. Your library never leaves the phone. The only network requests are searches and detail lookups sent to TMDB and Open Library, plus poster and cover image downloads.

## Roadmap

- [ ] Daily background check for new episodes, which also refreshes saved episode lists
- [ ] Lists and tags screen (Library tab)
- [ ] JSON export and import for backups

## License

Released under the [MIT License](LICENSE).

## Credits

This product uses the TMDB API but is not endorsed or certified by TMDB.

Movie and series metadata and images are provided by [TMDB](https://www.themoviedb.org/). Book data and covers are provided by [Open Library](https://openlibrary.org/).
