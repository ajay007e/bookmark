import 'dart:math' as math;

import '../data/app_database.dart';
import '../data/stats_queries.dart';

enum StatsPeriod {
  week('Week', 'This week'),
  month('Month', 'This month'),
  year('Year', 'This year'),
  all('All time', 'All time');

  const StatsPeriod(this.label, this.heading);

  final String label;
  final String heading;

  DateTime? get since {
    final n = DateTime.now();
    return switch (this) {
      StatsPeriod.week => DateTime(n.year, n.month, n.day - (n.weekday - 1)),
      StatsPeriod.month => DateTime(n.year, n.month),
      StatsPeriod.year => DateTime(n.year),
      StatsPeriod.all => null,
    };
  }
}

enum StatsFilter {
  all('All'),
  movies('Movies'),
  series('Series'),
  books('Books');

  const StatsFilter(this.label);

  final String label;

  bool accepts(MediaType t) => switch (this) {
    StatsFilter.all => true,
    StatsFilter.movies => t == MediaType.movie,
    StatsFilter.series => t == MediaType.series,
    StatsFilter.books => t == MediaType.book,
  };
}

typedef StatsKey = ({StatsPeriod period, StatsFilter filter});

String formatDuration(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

class StatBar {
  const StatBar(this.label, this.value);

  final String label;
  final int value;
}

class StatsSummary {
  const StatsSummary({
    required this.entries,
    required this.hasActivity,
    required this.titles,
    required this.minutes,
    required this.movies,
    required this.episodes,
    required this.books,
    required this.movieMinutes,
    required this.seriesMinutes,
    required this.activeDays,
    required this.avgPerDay,
    required this.busiestDay,
    required this.busiestValue,
    required this.bars,
    required this.genres,
    required this.avgMinutes,
    required this.longestTitle,
    required this.longestMinutes,
    required this.topTitle,
    required this.topMinutes,
    required this.pages,
    required this.readingMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.topAuthor,
    required this.topAuthorCount,
  });

  final int entries;
  final bool hasActivity;
  final int titles;
  final int minutes;
  final int movies;
  final int episodes;
  final int books;
  final int movieMinutes;
  final int seriesMinutes;
  final int activeDays;
  final int avgPerDay;
  final DateTime? busiestDay;
  final int busiestValue;
  final List<StatBar> bars;
  final List<({String name, int titles})> genres;
  final int avgMinutes;
  final String? longestTitle;
  final int longestMinutes;
  final String? topTitle;
  final int topMinutes;
  final int pages;
  final int readingMinutes;
  final int currentStreak;
  final int longestStreak;
  final String? topAuthor;
  final int topAuthorCount;
}

typedef _Point = ({DateTime at, int value});

({int current, int longest}) _streaks(Set<DateTime> days, DateTime now) {
  if (days.isEmpty) return (current: 0, longest: 0);

  final sorted = days.toList()..sort();
  var longest = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final prev = sorted[i - 1];
    final next = DateTime(prev.year, prev.month, prev.day + 1);
    run = sorted[i] == next ? run + 1 : 1;
    longest = math.max(longest, run);
  }

  var cursor = DateTime(now.year, now.month, now.day);
  if (!days.contains(cursor)) {
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  var current = 0;
  while (days.contains(cursor)) {
    current++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return (current: current, longest: longest);
}

StatsSummary buildSummary(
    List<StatEntry> all,
    StatsFilter filter,
    StatsPeriod period,
    DateTime now, {
      List<ReadEntry> reads = const [],
      Set<DateTime> readDays = const {},
    }) {
  final list = all.where((e) => filter.accepts(e.type)).toList();
  final bookView = filter == StatsFilter.books;

  var minutes = 0;
  var movies = 0;
  var episodes = 0;
  var books = 0;
  var movieMinutes = 0;
  var seriesMinutes = 0;
  for (final e in list) {
    minutes += e.minutes;
    switch (e.type) {
      case MediaType.movie:
        movies++;
        movieMinutes += e.minutes;
      case MediaType.series:
        episodes++;
        seriesMinutes += e.minutes;
      case MediaType.book:
        books++;
    }
  }
  final titles = {for (final e in list) e.itemId}.length;

  final perDay = <DateTime, int>{};
  var total = 0;
  if (bookView) {
    for (final r in reads) {
      final p = r.pages ?? 0;
      if (p <= 0) continue;
      final d = DateTime(r.readAt.year, r.readAt.month, r.readAt.day);
      perDay[d] = (perDay[d] ?? 0) + p;
      total += p;
    }
  } else {
    for (final e in list) {
      final d = DateTime(e.watchedAt.year, e.watchedAt.month, e.watchedAt.day);
      perDay[d] = (perDay[d] ?? 0) + e.minutes;
      total += e.minutes;
    }
  }
  DateTime? busiestDay;
  var busiestValue = 0;
  for (final entry in perDay.entries) {
    if (entry.value > busiestValue) {
      busiestValue = entry.value;
      busiestDay = entry.key;
    }
  }
  final avgPerDay = perDay.isEmpty ? 0 : (total / perDay.length).round();
  final activeDays = bookView
      ? {
    for (final r in reads)
      DateTime(r.readAt.year, r.readAt.month, r.readAt.day),
  }.length
      : perDay.length;

  final byGenre = <String, Set<int>>{};
  for (final e in list) {
    for (final g in e.genres) {
      (byGenre[g] ??= <int>{}).add(e.itemId);
    }
  }
  final genreList = [
    for (final g in byGenre.entries) (name: g.key, titles: g.value.length),
  ]..sort((a, b) => b.titles != a.titles
      ? b.titles.compareTo(a.titles)
      : a.name.compareTo(b.name));

  final timed = list.where((e) => e.minutes > 0).toList();
  final avgMinutes = timed.isEmpty
      ? 0
      : (timed.fold<int>(0, (s, e) => s + e.minutes) / timed.length).round();

  StatEntry? longest;
  for (final e in timed) {
    if (longest == null || e.minutes > longest.minutes) longest = e;
  }

  final minutesByItem = <int, int>{};
  final titleOf = <int, String>{};
  for (final e in list) {
    if (e.type == MediaType.book) continue;
    minutesByItem[e.itemId] = (minutesByItem[e.itemId] ?? 0) + e.minutes;
    titleOf[e.itemId] = e.title;
  }
  int? topId;
  var topMinutes = 0;
  for (final entry in minutesByItem.entries) {
    if (topId == null || entry.value > topMinutes) {
      topId = entry.key;
      topMinutes = entry.value;
    }
  }

  final byAuthor = <String, int>{};
  for (final e in list) {
    if (e.type != MediaType.book) continue;
    final a = e.author;
    if (a != null && a.isNotEmpty) byAuthor[a] = (byAuthor[a] ?? 0) + 1;
  }
  String? topAuthor;
  var topAuthorCount = 0;
  for (final entry in byAuthor.entries) {
    if (entry.value > topAuthorCount) {
      topAuthor = entry.key;
      topAuthorCount = entry.value;
    }
  }

  final streaks = bookView ? _streaks(readDays, now) : (current: 0, longest: 0);
  final points = bookView
      ? <_Point>[
    for (final r in reads)
      if ((r.pages ?? 0) > 0) (at: r.readAt, value: r.pages!),
  ]
      : <_Point>[for (final e in list) (at: e.watchedAt, value: e.minutes)];

  return StatsSummary(
    entries: list.length,
    hasActivity: bookView ? (list.isNotEmpty || reads.isNotEmpty) : list.isNotEmpty,
    titles: titles,
    minutes: minutes,
    movies: movies,
    episodes: episodes,
    books: books,
    movieMinutes: movieMinutes,
    seriesMinutes: seriesMinutes,
    activeDays: activeDays,
    avgPerDay: avgPerDay,
    busiestDay: busiestDay,
    busiestValue: busiestValue,
    bars: _bars(points, period, now),
    genres: genreList.take(8).toList(),
    avgMinutes: avgMinutes,
    longestTitle: longest?.title,
    longestMinutes: longest?.minutes ?? 0,
    topTitle: topId == null ? null : titleOf[topId],
    topMinutes: topMinutes,
    pages: bookView ? total : 0,
    readingMinutes: bookView ? reads.fold<int>(0, (s, r) => s + r.minutes) : 0,
    currentStreak: streaks.current,
    longestStreak: streaks.longest,
    topAuthor: topAuthor,
    topAuthorCount: topAuthorCount,
  );
}

List<StatBar> _bars(List<_Point> points, StatsPeriod period, DateTime now) {
  final List<String> labels;
  final int Function(DateTime) indexOf;

  switch (period) {
    case StatsPeriod.week:
      final start = DateTime.utc(now.year, now.month, now.day - (now.weekday - 1));
      labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      indexOf = (d) =>
      DateTime.utc(d.year, d.month, d.day).difference(start).inDays;
    case StatsPeriod.month:
      final days = DateTime(now.year, now.month + 1, 0).day;
      labels = [
        for (var i = 1; i <= days; i++) (i == 1 || i % 5 == 0) ? '$i' : '',
      ];
      indexOf = (d) => d.day - 1;
    case StatsPeriod.year:
      labels = const ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      indexOf = (d) => d.month - 1;
    case StatsPeriod.all:
      final first = points.isEmpty
          ? now.year
          : points.map((p) => p.at.year).reduce(math.min);
      final count = now.year - first + 1;
      labels = [
        for (var i = 0; i < count; i++)
          "'${((first + i) % 100).toString().padLeft(2, '0')}",
      ];
      indexOf = (d) => d.year - first;
  }

  final values = List<int>.filled(labels.length, 0);
  for (final p in points) {
    final i = indexOf(p.at);
    if (i >= 0 && i < values.length) values[i] += p.value;
  }
  return [for (var i = 0; i < labels.length; i++) StatBar(labels[i], values[i])];
}