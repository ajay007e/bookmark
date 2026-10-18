
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [MediaItems, Episodes, UserLists, ListEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'bookmark'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ---------- Writes ----------

  Future<int> addItem(MediaItemsCompanion item) =>
      into(mediaItems).insert(item, mode: InsertMode.insertOrIgnore);

  Future<void> setStatus(int id, Status status) =>
      (update(mediaItems)..where((t) => t.id.equals(id))).write(
        MediaItemsCompanion(
          status: Value(status),
          lastActivityAt: Value(DateTime.now()),
        ),
      );

  Future<void> setPage(int id, int page) =>
      (update(mediaItems)..where((t) => t.id.equals(id))).write(
        MediaItemsCompanion(
          currentPage: Value(page),
          lastActivityAt: Value(DateTime.now()),
        ),
      );

  // ---------- Home screen ----------

  /// Books being read, series being watched, and finished series that have
  /// aired but unwatched episodes (the "new episode available" case).
  Stream<List<MediaItem>> hero() {
    final query = customSelect(
      'SELECT * FROM media_items '
          'WHERE (type = ? AND status = ?) '
          '   OR (type = ? AND status = ?) '
          '   OR (type = ? AND status = ? AND id IN ('
          '        SELECT series_id FROM episodes '
          '        WHERE watched = 0 AND air_date IS NOT NULL AND air_date <= ?)) '
          'ORDER BY last_activity_at DESC',
      variables: [
        Variable.withInt(MediaType.book.index),
        Variable.withInt(Status.inProgress.index),
        Variable.withInt(MediaType.series.index),
        Variable.withInt(Status.inProgress.index),
        Variable.withInt(MediaType.series.index),
        Variable.withInt(Status.done.index),
        Variable.withDateTime(DateTime.now()),
      ],
      readsFrom: {mediaItems, episodes},
    );
    return query
        .watch()
        .map((rows) => rows.map((r) => mediaItems.map(r.data)).toList());
  }

  Stream<List<MediaItem>> recentWatched() => (select(mediaItems)
    ..where((t) =>
    t.type.isInValues([MediaType.movie, MediaType.series]) &
    t.status.isInValues([Status.inProgress, Status.done]))
    ..orderBy([(t) => OrderingTerm.desc(t.lastActivityAt)])
    ..limit(20))
      .watch();

  Stream<List<MediaItem>> recentRead() => (select(mediaItems)
    ..where((t) =>
    t.type.equalsValue(MediaType.book) &
    t.status.isInValues([Status.inProgress, Status.done]))
    ..orderBy([(t) => OrderingTerm.desc(t.lastActivityAt)])
    ..limit(20))
      .watch();

  Stream<List<MediaItem>> wishlist(MediaType type) => (select(mediaItems)
    ..where((t) =>
    t.type.equalsValue(type) & t.status.equalsValue(Status.want))
    ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
      .watch();

  Stream<List<MediaItem>> byType(MediaType type) => (select(mediaItems)
    ..where((t) => t.type.equalsValue(type))
    ..orderBy([(t) => OrderingTerm.desc(t.lastActivityAt)]))
      .watch();

  // ---------- Debug helper until search exists ----------

  Future<void> seedSamples() async {
    MediaItemsCompanion c(MediaType type, String id, String title, Status s,
        {String? author, int? pages, int page = 0}) =>
        MediaItemsCompanion.insert(
          type: type,
          externalId: id,
          title: title,
          status: Value(s),
          author: Value(author),
          pageCount: Value(pages),
          currentPage: Value(page),
        );

    await batch((b) {
      b.insertAll(
        mediaItems,
        [
          c(MediaType.series, 'sample-s1', 'Sample Series One', Status.inProgress),
          c(MediaType.series, 'sample-s2', 'Sample Series Two', Status.want),
          c(MediaType.movie, 'sample-m1', 'Sample Movie One', Status.done),
          c(MediaType.movie, 'sample-m2', 'Sample Movie Two', Status.want),
          c(MediaType.book, 'sample-b1', 'Sample Book One', Status.inProgress,
              author: 'A. Writer', pages: 320, page: 120),
          c(MediaType.book, 'sample-b2', 'Sample Book Two', Status.done,
              author: 'B. Author', pages: 280, page: 280),
          c(MediaType.book, 'sample-b3', 'Sample Book Three', Status.want,
              author: 'C. Novelist', pages: 410),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}