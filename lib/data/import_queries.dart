import 'dart:convert';

import 'package:drift/drift.dart' show Value, InsertMode;

import 'app_database.dart';
import 'export_queries.dart' show backupFormat;
import 'labels.dart';

// ---------- Reading the backup file ----------

T _req<T>(Map<String, dynamic> j, String k) {
  final v = j[k];
  if (v is T) return v;
  throw FormatException('Missing or invalid "$k" in the backup.');
}

T? _opt<T>(Map<String, dynamic> j, String k) {
  final v = j[k];
  if (v == null) return null;
  if (v is T) return v;
  throw FormatException('Invalid "$k" in the backup.');
}

T _enum<T extends Enum>(List<T> values, String name) => values.firstWhere(
      (v) => v.name == name,
  orElse: () => throw FormatException('Unknown value "$name" in the backup.'),
);

DateTime? _dateOpt(Map<String, dynamic> j, String k) {
  final s = _opt<String>(j, k);
  return s == null ? null : DateTime.parse(s);
}

Map<int, List<T>> _group<T>(List<T> list, int Function(T) by) {
  final m = <int, List<T>>{};
  for (final x in list) {
    (m[by(x)] ??= []).add(x);
  }
  return m;
}

// Keys used to recognise "the same thing" on the phone and in the backup.
String _itemKey(MediaType t, String externalId) => '${t.name}|$externalId';
String _epKey(int season, int episode) => '$season:$episode';
String _logKey(String ep, DateTime at, bool counted, int? minutes) =>
    '$ep|${at.toUtc().millisecondsSinceEpoch ~/ 1000}|$counted|${minutes ?? ''}';

class BackupItem {
  BackupItem(Map<String, dynamic> j)
      : id = _req<int>(j, 'id'),
        type = _enum(MediaType.values, _req<String>(j, 'type')),
        externalId = _req<String>(j, 'externalId'),
        title = _req<String>(j, 'title'),
        posterUrl = _opt<String>(j, 'posterUrl'),
        overview = _opt<String>(j, 'overview'),
        year = _opt<int>(j, 'year'),
        genres = _opt<String>(j, 'genres') ?? '',
        status = _enum(Status.values, _req<String>(j, 'status')),
        rating = _opt<int>(j, 'rating'),
        runtime = _opt<int>(j, 'runtime'),
        ongoing = _opt<bool>(j, 'ongoing'),
        author = _opt<String>(j, 'author'),
        pageCount = _opt<int>(j, 'pageCount'),
        currentPage = _opt<int>(j, 'currentPage') ?? 0,
        dropReason = _opt<String>(j, 'dropReason'),
        droppedAtPage = _opt<int>(j, 'droppedAtPage'),
        addedAt = _dateOpt(j, 'addedAt') ?? DateTime.now(),
        lastActivityAt = _dateOpt(j, 'lastActivityAt') ?? DateTime.now();

  final int id;
  final MediaType type;
  final String externalId;
  final String title;
  final String? posterUrl;
  final String? overview;
  final int? year;
  final String genres;
  final Status status;
  final int? rating;
  final int? runtime;
  final bool? ongoing;
  final String? author;
  final int? pageCount;
  final int currentPage;
  final String? dropReason;
  final int? droppedAtPage;
  final DateTime addedAt;
  final DateTime lastActivityAt;
}

class BackupEpisode {
  BackupEpisode(Map<String, dynamic> j)
      : seriesId = _req<int>(j, 'seriesId'),
        seasonNumber = _req<int>(j, 'seasonNumber'),
        episodeNumber = _req<int>(j, 'episodeNumber'),
        id = _req<int>(j, 'id'),
        title = _opt<String>(j, 'title'),
        airDate = _dateOpt(j, 'airDate'),
        runtime = _opt<int>(j, 'runtime'),
        watched = _opt<bool>(j, 'watched') ?? false,
        watchedAt = _dateOpt(j, 'watchedAt');

  final int id;
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String? title;
  final DateTime? airDate;
  final int? runtime;
  final bool watched;
  final DateTime? watchedAt;
}

class BackupLog {
  BackupLog(Map<String, dynamic> j)
      : itemId = _req<int>(j, 'itemId'),
        episodeId = _opt<int>(j, 'episodeId'),
        watchedAt = DateTime.parse(_req<String>(j, 'watchedAt')),
        counted = _opt<bool>(j, 'counted') ?? true,
        minutes = _opt<int>(j, 'minutes');

  final int itemId;
  final int? episodeId;
  final DateTime watchedAt;
  final bool counted;
  final int? minutes;
}

class BackupList {
  BackupList(Map<String, dynamic> j)
      : id = _req<int>(j, 'id'),
        name = _req<String>(j, 'name');

  final int id;
  final String name;
}

/// A backup file, read and checked. Throws FormatException with a message
/// for the user when the file is not a usable Bookmark backup.
class BackupFile {
  BackupFile._({
    required this.items,
    required this.episodes,
    required this.logs,
    required this.lists,
    required this.entries,
  });

  final List<BackupItem> items;
  final List<BackupEpisode> episodes;
  final List<BackupLog> logs;
  final List<BackupList> lists;
  final List<({int listId, int itemId})> entries;

  late final Map<int, List<BackupEpisode>> episodesBySeries =
  _group(episodes, (e) => e.seriesId);
  late final Map<int, List<BackupLog>> logsByItem =
  _group(logs, (l) => l.itemId);
  late final Map<int, String> epKeyById = {
    for (final e in episodes) e.id: _epKey(e.seasonNumber, e.episodeNumber),
  };

  /// "S:E" of the episode a log row belongs to, "-" for movies and books,
  /// null when the log points to an episode that is not in the file.
  String? logEpKey(BackupLog l) {
    final id = l.episodeId;
    if (id == null) return '-';
    return epKeyById[id];
  }

  Set<String> logKeys(int itemId) => {
    for (final l in logsByItem[itemId] ?? const <BackupLog>[])
      if (logEpKey(l) != null)
        _logKey(logEpKey(l)!, l.watchedAt, l.counted, l.minutes),
  };

  static BackupFile parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException('This file is not a valid JSON file.');
    }
    if (decoded is! Map<String, dynamic> || decoded['app'] != 'bookmark') {
      throw const FormatException('This is not a Bookmark backup file.');
    }
    // A variable that is already typed as a Map, so it also works
    // inside the helper function below.
    final Map<String, dynamic> root = decoded;

    final format = root['format'];
    if (format is! int) {
      throw const FormatException('This backup has no format version.');
    }
    if (format > backupFormat) {
      throw const FormatException(
        'This backup was made by a newer version of Bookmark. Update the app first.',
      );
    }

    List<T> read<T>(String key, T Function(Map<String, dynamic>) make) {
      final v = root[key];
      if (v == null) return <T>[]; // older backups may lack a table
      if (v is! List) throw FormatException('"$key" is not a list.');
      return [for (final e in v) make(e as Map<String, dynamic>)];
    }

    try {
      return BackupFile._(
        items: read('mediaItems', BackupItem.new),
        episodes: read('episodes', BackupEpisode.new),
        logs: read('watchLogs', BackupLog.new),
        lists: read('userLists', BackupList.new),
        entries: read(
          'listEntries',
              (j) => (listId: _req<int>(j, 'listId'), itemId: _req<int>(j, 'itemId')),
        ),
      );
    } on TypeError {
      throw const FormatException('The backup file is damaged.');
    }
  }
}

// ---------- Plan and report ----------

enum ImportChoice { keepPhone, useBackup, merge }

class ItemConflict {
  ItemConflict(this.item, this.reason);

  final BackupItem item;
  final String reason;
}

class ImportPreview {
  ImportPreview({
    required this.file,
    required this.phoneItemCount,
    required this.newItems,
    required this.identical,
    required this.conflicts,
  });

  final BackupFile file;
  final int phoneItemCount;
  final List<BackupItem> newItems;
  final int identical;
  final List<ItemConflict> conflicts;

  bool get libraryEmpty => phoneItemCount == 0;
}

class ImportReport {
  int added = 0;
  int merged = 0;
  int overwritten = 0;
  int kept = 0;
  int identical = 0;
  int listsAdded = 0;

  String get summary {
    final parts = <String>[
      if (added > 0) '$added added',
      if (merged > 0) '$merged merged',
      if (overwritten > 0) '$overwritten replaced from the backup',
      if (kept > 0) '$kept kept as on your phone',
      if (identical > 0) '$identical already the same',
      if (listsAdded > 0) '$listsAdded new list${listsAdded == 1 ? '' : 's'}',
    ];
    return parts.isEmpty ? 'Nothing to import.' : 'Import done: ${parts.join(', ')}.';
  }
}

Status _seriesStatus(bool? ongoing, List<Episode> eps) {
  final now = DateTime.now();
  final watched = eps.where((e) => e.watched).length;
  final unwatchedAired = eps
      .where((e) => !e.watched && e.airDate != null && !e.airDate!.isAfter(now))
      .length;
  if (watched == 0) return Status.want;
  final running = ongoing ?? true; // not known yet = treated as running
  return (!running && unwatchedAired == 0) ? Status.done : Status.inProgress;
}

String? _fill(String? keep, String? other) =>
    (keep == null || keep.isEmpty) ? other : keep;

extension ImportQueries on AppDatabase {
  // ---------- Step 1: compare (changes nothing) ----------

  Future<ImportPreview> analyzeBackup(BackupFile f) async {
    final items = await select(mediaItems).get();
    final phoneByKey = {for (final i in items) _itemKey(i.type, i.externalId): i};

    final allEps = await select(episodes).get();
    final epsByItem = _group(allEps, (e) => e.seriesId);
    final epKeyById = {
      for (final e in allEps) e.id: _epKey(e.seasonNumber, e.episodeNumber),
    };
    final logKeysByItem = <int, Set<String>>{};
    for (final l in await select(watchLogs).get()) {
      final ep = l.episodeId == null ? '-' : (epKeyById[l.episodeId] ?? '?');
      (logKeysByItem[l.itemId] ??= {})
          .add(_logKey(ep, l.watchedAt, l.counted, l.minutes));
    }

    final newItems = <BackupItem>[];
    final conflicts = <ItemConflict>[];
    var identical = 0;

    for (final b in f.items) {
      final p = phoneByKey[_itemKey(b.type, b.externalId)];
      if (p == null) {
        newItems.add(b);
        continue;
      }
      final why = _difference(
        f,
        b,
        p,
        epsByItem[p.id] ?? const <Episode>[],
        logKeysByItem[p.id] ?? const <String>{},
      );
      if (why == null) {
        identical++;
      } else {
        conflicts.add(ItemConflict(b, why));
      }
    }

    return ImportPreview(
      file: f,
      phoneItemCount: items.length,
      newItems: newItems,
      identical: identical,
      conflicts: conflicts,
    );
  }

  /// null = the progress is the same on both sides. Otherwise the reason.
  String? _difference(
      BackupFile f,
      BackupItem b,
      MediaItem p,
      List<Episode> pEps,
      Set<String> pLogs,
      ) {
    if (b.status != p.status) {
      return 'Phone: ${statusLabel(p.type, p.status)}, '
          'backup: ${statusLabel(b.type, b.status)}';
    }
    if (b.dropReason != p.dropReason || b.droppedAtPage != p.droppedAtPage) {
      return 'Stop details differ';
    }
    final bw = {
      for (final e in f.episodesBySeries[b.id] ?? const <BackupEpisode>[])
        if (e.watched) _epKey(e.seasonNumber, e.episodeNumber),
    };
    final pw = {
      for (final e in pEps)
        if (e.watched) _epKey(e.seasonNumber, e.episodeNumber),
    };
    if (bw.length != pw.length || !bw.containsAll(pw)) {
      return 'Phone: ${pw.length} episodes watched, backup: ${bw.length}';
    }
    final bl = f.logKeys(b.id);
    if (bl.length != pLogs.length || !bl.containsAll(pLogs)) {
      return 'Watch history differs';
    }
    return null;
  }

  // ---------- Step 2: apply (one transaction, all or nothing) ----------

  Future<ImportReport> applyBackup(ImportPreview pv, ImportChoice choice) =>
      transaction(() async {
        final f = pv.file;
        final report = ImportReport();
        final conflictKeys = {
          for (final c in pv.conflicts)
            _itemKey(c.item.type, c.item.externalId),
        };

        final phone = {
          for (final i in await select(mediaItems).get())
            _itemKey(i.type, i.externalId): i,
        };

        // Backup item id -> id of the same item on this phone.
        final idMap = <int, int>{};

        for (final b in f.items) {
          final key = _itemKey(b.type, b.externalId);
          final existing = phone[key];
          if (existing == null) {
            idMap[b.id] = await _insertNew(f, b);
            report.added++;
            continue;
          }
          idMap[b.id] = existing.id;
          if (!conflictKeys.contains(key)) {
            report.identical++;
            continue;
          }
          switch (choice) {
            case ImportChoice.keepPhone:
              report.kept++;
            case ImportChoice.useBackup:
              await _overwrite(f, b, existing);
              report.overwritten++;
            case ImportChoice.merge:
              await _merge(f, b, existing);
              report.merged++;
          }
        }

        // Lists: joined by name, entries combined.
        final byName = {
          for (final l in await select(userLists).get())
            l.name.toLowerCase(): l.id,
        };
        final listIdMap = <int, int>{};
        for (final l in f.lists) {
          final name = l.name.trim();
          if (name.isEmpty) continue;
          var id = byName[name.toLowerCase()];
          if (id == null) {
            id = await into(userLists).insert(UserListsCompanion.insert(name: name));
            byName[name.toLowerCase()] = id;
            report.listsAdded++;
          }
          listIdMap[l.id] = id;
        }
        for (final e in f.entries) {
          final listId = listIdMap[e.listId];
          final itemId = idMap[e.itemId];
          if (listId == null || itemId == null) continue;
          await into(listEntries).insert(
            ListEntriesCompanion.insert(listId: listId, itemId: itemId),
            mode: InsertMode.insertOrIgnore,
          );
        }

        return report;
      });

  Future<int> _insertNew(BackupFile f, BackupItem b) async {
    final id = await into(mediaItems).insert(MediaItemsCompanion.insert(
      type: b.type,
      externalId: b.externalId,
      title: b.title,
      posterUrl: Value(b.posterUrl),
      overview: Value(b.overview),
      year: Value(b.year),
      genres: Value(b.genres),
      status: Value(b.status),
      rating: Value(b.rating),
      runtime: Value(b.runtime),
      ongoing: Value(b.ongoing),
      author: Value(b.author),
      pageCount: Value(b.pageCount),
      currentPage: Value(b.currentPage),
      dropReason: Value(b.dropReason),
      droppedAtPage: Value(b.droppedAtPage),
      addedAt: Value(b.addedAt),
      lastActivityAt: Value(b.lastActivityAt),
    ));
    await _addMissingEpisodes(f.episodesBySeries[b.id] ?? const [], id, const {});
    await _importLogs(f, b.id, id);
    return id;
  }

  /// Inserts backup episodes whose season and number are not in [have].
  Future<void> _addMissingEpisodes(
      List<BackupEpisode> list,
      int seriesId,
      Set<String> have,
      ) async {
    final rows = [
      for (final e in list)
        if (!have.contains(_epKey(e.seasonNumber, e.episodeNumber)))
          EpisodesCompanion.insert(
            seriesId: seriesId,
            seasonNumber: e.seasonNumber,
            episodeNumber: e.episodeNumber,
            title: Value(e.title),
            airDate: Value(e.airDate),
            runtime: Value(e.runtime),
            watched: Value(e.watched),
            watchedAt: Value(e.watchedAt),
          ),
    ];
    if (rows.isEmpty) return;
    await batch((x) => x.insertAll(episodes, rows, mode: InsertMode.insertOrIgnore));
  }

  Future<Set<String>> _phoneLogKeys(int itemId) async {
    final eps = await episodesOf(itemId);
    final keyById = {
      for (final e in eps) e.id: _epKey(e.seasonNumber, e.episodeNumber),
    };
    final logs =
    await (select(watchLogs)..where((l) => l.itemId.equals(itemId))).get();
    return {
      for (final l in logs)
        _logKey(
          l.episodeId == null ? '-' : (keyById[l.episodeId] ?? '?'),
          l.watchedAt,
          l.counted,
          l.minutes,
        ),
    };
  }

  /// Copies the backup's history rows of one item. Rows already in [existing]
  /// are skipped. [allow] can leave out rows (by episode key, "-" = item level).
  Future<void> _importLogs(
      BackupFile f,
      int backupItemId,
      int phoneItemId, {
        Set<String> existing = const {},
        bool Function(String epKey)? allow,
      }) async {
    final rows = await episodesOf(phoneItemId);
    final idByKey = {
      for (final e in rows) _epKey(e.seasonNumber, e.episodeNumber): e.id,
    };
    final seen = {...existing};
    final toAdd = <WatchLogsCompanion>[];

    for (final l in f.logsByItem[backupItemId] ?? const <BackupLog>[]) {
      final ek = f.logEpKey(l);
      if (ek == null) continue;
      if (allow != null && !allow(ek)) continue;
      int? phoneEp;
      if (ek != '-') {
        phoneEp = idByKey[ek];
        if (phoneEp == null) continue;
      }
      if (!seen.add(_logKey(ek, l.watchedAt, l.counted, l.minutes))) continue;
      toAdd.add(WatchLogsCompanion.insert(
        itemId: phoneItemId,
        watchedAt: l.watchedAt,
        episodeId: Value(phoneEp),
        counted: Value(l.counted),
        minutes: Value(l.minutes),
      ));
    }
    if (toAdd.isNotEmpty) await batch((x) => x.insertAll(watchLogs, toAdd));
  }

  // ---------- Merge both ----------

  Future<void> _merge(BackupFile f, BackupItem b, MediaItem p) async {
    final series = p.type == MediaType.series;
    final bEps = f.episodesBySeries[b.id] ?? const <BackupEpisode>[];
    final pEps = await episodesOf(p.id);
    final pByKey = {
      for (final e in pEps) _epKey(e.seasonNumber, e.episodeNumber): e,
    };

    // Episodes: a tick on either side stays. Missing episodes are added.
    for (final e in bEps) {
      final old = pByKey[_epKey(e.seasonNumber, e.episodeNumber)];
      if (old != null && e.watched && !old.watched) {
        await (update(episodes)..where((t) => t.id.equals(old.id))).write(
          EpisodesCompanion(
            watched: const Value(true),
            watchedAt: Value(e.watchedAt),
          ),
        );
      }
    }
    await _addMissingEpisodes(bEps, p.id, pByKey.keys.toSet());

    // Item: the side with the later activity decides the status.
    final backupNewer = b.lastActivityAt.isAfter(p.lastActivityAt);
    var status = backupNewer ? b.status : p.status;
    final ongoing = p.ongoing ?? b.ongoing;
    if (series) status = _seriesStatus(ongoing, await episodesOf(p.id));
    final dropped = status == Status.dropped;

    await (update(mediaItems)..where((t) => t.id.equals(p.id))).write(
      MediaItemsCompanion(
        status: Value(status),
        dropReason: Value(dropped ? (backupNewer ? b.dropReason : p.dropReason) : null),
        droppedAtPage:
        Value(dropped ? (backupNewer ? b.droppedAtPage : p.droppedAtPage) : null),
        posterUrl: Value(_fill(p.posterUrl, b.posterUrl)),
        overview: Value(_fill(p.overview, b.overview)),
        year: Value(p.year ?? b.year),
        genres: Value(_fill(p.genres, b.genres) ?? ''),
        runtime: Value(p.runtime ?? b.runtime),
        ongoing: Value(ongoing),
        author: Value(_fill(p.author, b.author)),
        pageCount: Value(p.pageCount ?? b.pageCount),
        addedAt: Value(b.addedAt.isBefore(p.addedAt) ? b.addedAt : p.addedAt),
        lastActivityAt: Value(
          b.lastActivityAt.isAfter(p.lastActivityAt) ? b.lastActivityAt : p.lastActivityAt,
        ),
      ),
    );

    // History: union. Only rows that match the merged state are added.
    final existing = await _phoneLogKeys(p.id);
    if (series) {
      final watchedKeys = {
        for (final e in await episodesOf(p.id))
          if (e.watched) _epKey(e.seasonNumber, e.episodeNumber),
      };
      await _importLogs(f, b.id, p.id,
          existing: existing, allow: watchedKeys.contains);
    } else {
      await _importLogs(f, b.id, p.id,
          existing: existing, allow: (_) => status == Status.done);
    }
  }

  // ---------- Use the backup's version ----------

  Future<void> _overwrite(BackupFile f, BackupItem b, MediaItem p) async {
    final series = p.type == MediaType.series;
    final bEps = f.episodesBySeries[b.id] ?? const <BackupEpisode>[];
    final bByKey = {
      for (final e in bEps) _epKey(e.seasonNumber, e.episodeNumber): e,
    };
    final pEps = await episodesOf(p.id);

    // Every episode on the phone takes the backup's tick state.
    for (final e in pEps) {
      final be = bByKey[_epKey(e.seasonNumber, e.episodeNumber)];
      final watched = be?.watched ?? false;
      final watchedAt = watched ? be?.watchedAt : null;
      if (e.watched != watched || e.watchedAt != watchedAt) {
        await (update(episodes)..where((t) => t.id.equals(e.id))).write(
          EpisodesCompanion(watched: Value(watched), watchedAt: Value(watchedAt)),
        );
      }
    }
    await _addMissingEpisodes(
      bEps,
      p.id,
      {for (final e in pEps) _epKey(e.seasonNumber, e.episodeNumber)},
    );

    // History: the backup's rows replace the phone's.
    await (delete(watchLogs)..where((l) => l.itemId.equals(p.id))).go();
    await _importLogs(f, b.id, p.id);

    final status = series
        ? _seriesStatus(p.ongoing ?? b.ongoing, await episodesOf(p.id))
        : b.status;
    final dropped = status == Status.dropped;

    await (update(mediaItems)..where((t) => t.id.equals(p.id))).write(
      MediaItemsCompanion(
        status: Value(status),
        dropReason: Value(dropped ? b.dropReason : null),
        droppedAtPage: Value(dropped ? b.droppedAtPage : null),
        posterUrl: Value(_fill(b.posterUrl, p.posterUrl)),
        overview: Value(_fill(b.overview, p.overview)),
        year: Value(b.year ?? p.year),
        genres: Value(_fill(b.genres, p.genres) ?? ''),
        runtime: Value(b.runtime ?? p.runtime),
        ongoing: Value(p.ongoing ?? b.ongoing),
        author: Value(_fill(b.author, p.author)),
        pageCount: Value(b.pageCount ?? p.pageCount),
        addedAt: Value(b.addedAt),
        lastActivityAt: Value(b.lastActivityAt),
      ),
    );
  }
}