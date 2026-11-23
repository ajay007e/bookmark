import 'package:drift/drift.dart';

import 'app_database.dart';

typedef WatchStats = ({int minutes, int movies, int episodes, int books});

class StatEntry {
  const StatEntry({
    required this.type,
    required this.itemId,
    required this.title,
    required this.genres,
    required this.author,
    required this.pageCount,
    required this.watchedAt,
    required this.minutes,
  });

  final MediaType type;
  final int itemId;
  final String title;
  final List<String> genres;
  final String? author;
  final int? pageCount;
  final DateTime watchedAt;
  final int minutes;
}

class ReadEntry {
  const ReadEntry({required this.readAt, required this.pages, required this.minutes});

  final DateTime readAt;
  final int? pages;
  final int minutes;
}

extension StatsQueries on AppDatabase {
  Stream<List<StatEntry>> watchStatEntries(DateTime? since) {
    Expression<bool> condition = watchLogs.counted.equals(true);
    if (since != null) {
      condition = condition & watchLogs.watchedAt.isBiggerOrEqualValue(since);
    }

    final query = select(watchLogs).join([
      innerJoin(mediaItems, mediaItems.id.equalsExp(watchLogs.itemId)),
    ])
      ..where(condition);

    return query.watch().map((rows) {
      return [
        for (final r in rows)
          StatEntry(
            type: r.readTable(mediaItems).type,
            itemId: r.readTable(mediaItems).id,
            title: r.readTable(mediaItems).title,
            genres: r
                .readTable(mediaItems)
                .genres
                .split(',')
                .map((g) => g.trim())
                .where((g) => g.isNotEmpty)
                .toList(),
            author: r.readTable(mediaItems).author,
            pageCount: r.readTable(mediaItems).pageCount,
            watchedAt: r.readTable(watchLogs).watchedAt,
            minutes: r.readTable(watchLogs).minutes ?? 0,
          ),
      ];
    });
  }

  Stream<List<ReadEntry>> watchReadEntries(DateTime? since) {
    final query = select(readingLogs);
    if (since != null) {
      query.where((l) => l.readAt.isBiggerOrEqualValue(since));
    }
    return query.watch().map((rows) => [
      for (final r in rows)
        ReadEntry(readAt: r.readAt, pages: r.pages, minutes: r.minutes ?? 0),
    ]);
  }

  Stream<Set<DateTime>> watchReadDays() =>
      select(readingLogs).watch().map((rows) => {
        for (final r in rows)
          DateTime(r.readAt.year, r.readAt.month, r.readAt.day),
      });

  Stream<WatchStats> watchStats(DateTime? since) =>
      watchStatEntries(since).map((entries) {
        var minutes = 0;
        var movies = 0;
        var episodes = 0;
        var books = 0;
        for (final e in entries) {
          minutes += e.minutes;
          switch (e.type) {
            case MediaType.movie:
              movies++;
            case MediaType.series:
              episodes++;
            case MediaType.book:
              books++;
          }
        }
        return (minutes: minutes, movies: movies, episodes: episodes, books: books);
      });
}