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
          dropReason: status == Status.dropped
              ? const Value.absent()
              : const Value(null),
          droppedAtPage: status == Status.dropped
              ? const Value.absent()
              : const Value(null),
          lastActivityAt: Value(DateTime.now()),
        ),
      );

  /// "Did not complete": both reason and page are optional.
  Future<void> setDropped(int id, String? reason, int? page) =>
      (update(mediaItems)..where((t) => t.id.equals(id))).write(
        MediaItemsCompanion(
          status: const Value(Status.dropped),
          dropReason: Value(reason),
          droppedAtPage: Value(page),
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

  // ---------- Item detail ----------

  Stream<MediaItem?> watchItem(int id) =>
      (select(mediaItems)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// rating is 1 to 5, or null to clear it.
  Future<void> setRating(int id, int? rating) =>
      (update(mediaItems)..where((t) => t.id.equals(id))).write(
        MediaItemsCompanion(
          rating: Value(rating),
          lastActivityAt: Value(DateTime.now()),
        ),
      );

  /// Episodes and list entries are removed too (cascade).
  Future<void> deleteItem(int id) =>
      (delete(mediaItems)..where((t) => t.id.equals(id))).go();

  // ---------- Series episodes ----------

  Stream<List<Episode>> watchEpisodes(int seriesId) => (select(episodes)
    ..where((e) => e.seriesId.equals(seriesId))
    ..orderBy([
          (e) => OrderingTerm.asc(e.seasonNumber),
          (e) => OrderingTerm.asc(e.episodeNumber),
    ]))
      .watch();

  /// Ticks or unticks episodes, then fixes the series status:
  /// nothing watched -> want, every aired episode watched -> done,
  /// anything in between -> inProgress.
  Future<void> setEpisodesWatched(
      int seriesId,
      Iterable<int> ids,
      bool watched,
      ) async {
    if (ids.isEmpty) return;
    await transaction(() async {
      final now = DateTime.now();
      await (update(episodes)..where((e) => e.id.isIn(ids))).write(
        EpisodesCompanion(
          watched: Value(watched),
          watchedAt: Value(watched ? now : null),
        ),
      );
      await _refreshSeriesStatus(seriesId, touch: watched);
    });
  }

  /// Unticks every episode and moves the series back to "want".
  Future<void> clearSeriesProgress(int seriesId) => transaction(() async {
    await (update(episodes)..where((e) => e.seriesId.equals(seriesId)))
        .write(EpisodesCompanion(
      watched: const Value(false),
      watchedAt: const Value(null),
    ));
    await _refreshSeriesStatus(seriesId, touch: false);
  });

  Future<void> _refreshSeriesStatus(int seriesId, {required bool touch}) async {
    final rows =
    await (select(episodes)..where((e) => e.seriesId.equals(seriesId))).get();
    final now = DateTime.now();
    final watchedCount = rows.where((e) => e.watched).length;
    final unwatchedAired = rows
        .where((e) =>
    !e.watched && e.airDate != null && !e.airDate!.isAfter(now))
        .length;

    final status = watchedCount == 0
        ? Status.want
        : (unwatchedAired == 0 ? Status.done : Status.inProgress);

    await (update(mediaItems)..where((t) => t.id.equals(seriesId))).write(
      MediaItemsCompanion(
        status: Value(status),
        // Only real watching counts as activity (it moves the series up
        // "Recently watched").
        lastActivityAt: touch ? Value(now) : const Value.absent(),
      ),
    );
  }

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

  // ---------- Search / add helpers ----------

  Future<int?> findId(MediaType type, String externalId) async {
    final row = await (select(mediaItems)
      ..where((t) =>
      t.type.equalsValue(type) & t.externalId.equals(externalId)))
        .getSingleOrNull();
    return row?.id;
  }

  Future<void> insertEpisodes(List<EpisodesCompanion> list) => batch(
        (b) => b.insertAll(episodes, list, mode: InsertMode.insertOrIgnore),
  );

  Stream<int> itemCount() {
    final count = mediaItems.id.count();
    return (selectOnly(mediaItems)..addColumns([count]))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }
}