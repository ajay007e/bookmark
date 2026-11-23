import 'package:drift/drift.dart';

import 'app_database.dart';

String? _iso(DateTime? d) => d?.toUtc().toIso8601String();

const backupFormat = 1;

extension ExportQueries on AppDatabase {
  Future<Map<String, Object?>> exportData() async {
    final items = await (select(mediaItems)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final eps = await (select(episodes)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final logs = await (select(watchLogs)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final reading = await (select(readingLogs)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final lists = await (select(userLists)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final entries = await select(listEntries).get();

    return {
      'app': 'bookmark',
      'format': backupFormat,
      'schemaVersion': schemaVersion,
      'exportedAt': _iso(DateTime.now()),
      'counts': {
        'mediaItems': items.length,
        'episodes': eps.length,
        'watchLogs': logs.length,
        'readingLogs': reading.length,
        'userLists': lists.length,
        'listEntries': entries.length,
      },
      'mediaItems': [
        for (final i in items)
          {
            'id': i.id,
            'type': i.type.name,
            'externalId': i.externalId,
            'title': i.title,
            'posterUrl': i.posterUrl,
            'overview': i.overview,
            'year': i.year,
            'genres': i.genres,
            'status': i.status.name,
            'rating': i.rating,
            'runtime': i.runtime,
            'ongoing': i.ongoing,
            'author': i.author,
            'pageCount': i.pageCount,
            'currentPage': i.currentPage,
            'progressUnit': i.progressUnit?.name,
            'dropReason': i.dropReason,
            'droppedAtPage': i.droppedAtPage,
            'addedAt': _iso(i.addedAt),
            'lastActivityAt': _iso(i.lastActivityAt),
          },
      ],
      'episodes': [
        for (final e in eps)
          {
            'id': e.id,
            'seriesId': e.seriesId,
            'seasonNumber': e.seasonNumber,
            'episodeNumber': e.episodeNumber,
            'title': e.title,
            'airDate': _iso(e.airDate),
            'runtime': e.runtime,
            'watched': e.watched,
            'watchedAt': _iso(e.watchedAt),
          },
      ],
      'watchLogs': [
        for (final l in logs)
          {
            'id': l.id,
            'itemId': l.itemId,
            'episodeId': l.episodeId,
            'watchedAt': _iso(l.watchedAt),
            'counted': l.counted,
            'minutes': l.minutes,
          },
      ],
      'readingLogs': [
        for (final r in reading)
          {
            'id': r.id,
            'itemId': r.itemId,
            'readAt': _iso(r.readAt),
            'fromPage': r.fromPage,
            'toPage': r.toPage,
            'pages': r.pages,
            'minutes': r.minutes,
            'inPercent': r.inPercent,
          },
      ],
      'userLists': [
        for (final l in lists) {'id': l.id, 'name': l.name},
      ],
      'listEntries': [
        for (final e in entries) {'listId': e.listId, 'itemId': e.itemId},
      ],
    };
  }
}