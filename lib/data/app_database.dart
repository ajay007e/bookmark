import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [MediaItems, Episodes, UserLists, ListEntries, WatchLogs],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'bookmark'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(mediaItems, mediaItems.runtime);
        await m.addColumn(mediaItems, mediaItems.ongoing);
        await m.addColumn(episodes, episodes.runtime);
        await m.createTable(watchLogs);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ---------- Writes ----------

  Future<int> addItem(MediaItemsCompanion item) =>
      into(mediaItems).insert(item, mode: InsertMode.insertOrIgnore);

  /// [touch] false keeps the item where it is in "Recently ..." lists
  /// (used for "watched earlier").
  Future<void> setStatus(int id, Status status, {bool touch = true}) =>
      (update(mediaItems)..where((t) => t.id.equals(id))).write(
        MediaItemsCompanion(
          status: Value(status),
          dropReason: status == Status.dropped
              ? const Value.absent()
              : const Value(null),
          droppedAtPage: status == Status.dropped
              ? const Value.absent()
              : const Value(null),
          lastActivityAt:
          touch ? Value(DateTime.now()) : const Value.absent(),
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

  /// Fills in details that older items do not have yet.
  Future<void> saveMeta(int id, {int? runtime, bool? ongoing}) async {
    if (runtime == null && ongoing == null) return;
    await (update(mediaItems)..where((t) => t.id.equals(id))).write(
      MediaItemsCompanion(
        runtime: runtime == null ? const Value.absent() : Value(runtime),
        ongoing: ongoing == null ? const Value.absent() : Value(ongoing),
      ),
    );
    if (ongoing != null) {
      // Whether a show is still running decides if it can be "Watched".
      final ticked = await (select(episodes)
        ..where((e) => e.seriesId.equals(id) & e.watched.equals(true))
        ..limit(1))
          .get();
      if (ticked.isNotEmpty) await _refreshSeriesStatus(id, touch: false);
    }
  }

  // ---------- Item detail ----------

  Stream<MediaItem?> watchItem(int id) =>
      (select(mediaItems)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// rating is 1 to 5, or null to clear it. (Unused for now.)
  Future<void> setRating(int id, int? rating) =>
      (update(mediaItems)..where((t) => t.id.equals(id))).write(
        MediaItemsCompanion(
          rating: Value(rating),
          lastActivityAt: Value(DateTime.now()),
        ),
      );

  /// Episodes, history and list entries are removed too (cascade).
  Future<void> deleteItem(int id) =>
      (delete(mediaItems)..where((t) => t.id.equals(id))).go();

  // ---------- Watch history (movies and books) ----------

  Future<void> addLog(
      int itemId, {
        int? episodeId,
        required bool counted,
        int? minutes,
      }) =>
      into(watchLogs).insert(WatchLogsCompanion.insert(
        itemId: itemId,
        watchedAt: DateTime.now(),
        episodeId: Value(episodeId),
        counted: Value(counted),
        minutes: Value(minutes),
      ));

  /// Movie watched or book read. [counted] false means "earlier":
  /// it is saved in the history but left out of the timeline.
  Future<void> markDone(MediaItem item, {required bool counted}) =>
      transaction(() async {
        await setStatus(item.id, Status.done, touch: counted);
        await addLog(
          item.id,
          counted: counted,
          minutes: item.type == MediaType.movie ? item.runtime : null,
        );
      });

  /// Removes the latest watch. If no history is left the item goes back
  /// to the wishlist.
  Future<void> markUnwatched(int itemId) => transaction(() async {
    final rows = await (select(watchLogs)
      ..where((l) => l.itemId.equals(itemId) & l.episodeId.isNull())
      ..orderBy([
            (l) => OrderingTerm.desc(l.watchedAt),
            (l) => OrderingTerm.desc(l.id),
      ]))
        .get();
    if (rows.isNotEmpty) {
      await (delete(watchLogs)..where((l) => l.id.equals(rows.first.id)))
          .go();
    }
    if (rows.length <= 1) {
      await setStatus(itemId, Status.want, touch: false);
    }
  });

  // ---------- Series episodes ----------

  Stream<List<Episode>> watchEpisodes(int seriesId) => (select(episodes)
    ..where((e) => e.seriesId.equals(seriesId))
    ..orderBy([
          (e) => OrderingTerm.asc(e.seasonNumber),
          (e) => OrderingTerm.asc(e.episodeNumber),
    ]))
      .watch();

  Future<List<Episode>> episodesOf(int seriesId) =>
      (select(episodes)..where((e) => e.seriesId.equals(seriesId))).get();

  /// Ticks or unticks episodes, writes or removes their history, then fixes
  /// the series status. [counted] false = "watched earlier".
  Future<void> setEpisodesWatched(
      int seriesId,
      Iterable<int> ids,
      bool watched, {
        bool counted = true,
      }) async {
    if (ids.isEmpty) return;
    await transaction(() async {
      final now = DateTime.now();
      if (watched) {
        final series = await (select(mediaItems)
          ..where((t) => t.id.equals(seriesId)))
            .getSingle();
        final rows =
        await (select(episodes)..where((e) => e.id.isIn(ids))).get();
        await batch((b) => b.insertAll(watchLogs, [
          for (final e in rows.where((e) => !e.watched))
            WatchLogsCompanion.insert(
              itemId: seriesId,
              watchedAt: now,
              episodeId: Value(e.id),
              counted: Value(counted),
              minutes: Value(e.runtime ?? series.runtime),
            ),
        ]));
      } else {
        await (delete(watchLogs)..where((l) => l.episodeId.isIn(ids))).go();
      }
      await (update(episodes)..where((e) => e.id.isIn(ids))).write(
        EpisodesCompanion(
          watched: Value(watched),
          watchedAt: Value(watched ? now : null),
        ),
      );
      await _refreshSeriesStatus(seriesId, touch: watched && counted);
    });
  }

  /// Unticks every episode, removes their history, and moves the series back
  /// to "want".
  Future<void> clearSeriesProgress(int seriesId) => transaction(() async {
    await (delete(watchLogs)..where((l) => l.itemId.equals(seriesId))).go();
    await (update(episodes)..where((e) => e.seriesId.equals(seriesId)))
        .write(EpisodesCompanion(
      watched: const Value(false),
      watchedAt: const Value(null),
    ));
    await _refreshSeriesStatus(seriesId, touch: false);
  });

  /// Fills in missing episode runtimes (series added before this was saved).
  Future<void> fillEpisodeRuntimes(
      int seriesId,
      int season,
      Map<int, int> runtimes,
      ) =>
      batch((b) {
        runtimes.forEach((number, minutes) {
          b.update(
            episodes,
            EpisodesCompanion(runtime: Value(minutes)),
            where: (e) =>
            e.seriesId.equals(seriesId) &
            e.seasonNumber.equals(season) &
            e.episodeNumber.equals(number) &
            e.runtime.isNull(),
          );
        });
      });

  /// Nothing ticked -> want. Still running (or not known yet) -> inProgress.
  /// Ended and every aired episode ticked -> done. Otherwise inProgress.
  Future<void> _refreshSeriesStatus(int seriesId, {required bool touch}) async {
    final series = await (select(mediaItems)
      ..where((t) => t.id.equals(seriesId)))
        .getSingleOrNull();
    if (series == null) return;

    final rows = await episodesOf(seriesId);
    final now = DateTime.now();
    final watchedCount = rows.where((e) => e.watched).length;
    final unwatchedAired = rows
        .where((e) =>
    !e.watched && e.airDate != null && !e.airDate!.isAfter(now))
        .length;
    final ongoing = series.ongoing ?? true;

    final status = watchedCount == 0
        ? Status.want
        : (!ongoing && unwatchedAired == 0 ? Status.done : Status.inProgress);

    await (update(mediaItems)..where((t) => t.id.equals(seriesId))).write(
      MediaItemsCompanion(
        status: Value(status),
        lastActivityAt: touch ? Value(now) : const Value.absent(),
      ),
    );
  }

  // ---------- Home screen ----------

  /// Books being read, series being watched, and finished series that have
  /// aired but unwatched episodes.
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