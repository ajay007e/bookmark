import 'package:drift/drift.dart';

import 'app_database.dart';

extension HeroQueries on AppDatabase {
  /// Movies in Want to watch for the Home hero, newest added first.
  Stream<List<MediaItem>> wantMoviesForHero({int limit = 10}) =>
      (select(mediaItems)
        ..where((t) =>
        t.type.equalsValue(MediaType.movie) &
        t.status.equalsValue(Status.want))
        ..orderBy([(t) => OrderingTerm.desc(t.addedAt)])
        ..limit(limit))
          .watch();
}