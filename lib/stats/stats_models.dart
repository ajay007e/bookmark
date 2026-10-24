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

  /// Start of the period (calendar based), or null for all time.
  DateTime? get since {
    final n = DateTime.now();
    return switch (this) {
    // Monday of this week, at midnight
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

/// 95 -> "1h 35m", 40 -> "40m", 120 -> "2h".
String formatDuration(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// One bar of the activity chart.
class StatBar {
  const StatBar(this.label, this.value);

  final String label;
  final int value;
}

class StatsSummary {
  const StatsSummary({
    required this.entries,
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
    required this.avgPages,
    required this.topAuthor,
    required this.topAuthorCount,
  });

  final int entries; // counted watches or reads
  final int titles; // different movies, series or books
  final int minutes;
  final int movies;
  final int episodes;
  final int books;
  final int movieMinutes;
  final int seriesMinutes;
  final int activeDays;
  final int avgPerDay; // minutes, or books when the Books view is open
  final DateTime? busiestDay;
  final int busiestValue; // minutes, or books when the Books view is open
  final List<StatBar> bars;
  final List<({String name, int titles})> genres;
  final int avgMinutes; // average movie length or episode length
  final String? longestTitle;
  final int longestMinutes;
  final String? topTitle; // most watched movie or series (by time)
  final int topMinutes;
  final int pages;
  final int avgPages;
  final String? topAuthor;
  final int topAuthorCount;
}

/// Turns the raw history rows into every number the stats page shows.
StatsSummary buildSummary(
    List<StatEntry> all,
    StatsFilter filter,
    StatsPeriod period,
    DateTime now,
    ) {
  final list = all.where((e) => filter.accepts(e.type)).toList();

  // The Books view counts books. Every other view counts minutes.
  final countMode = filter == StatsFilter.books;
  int valueOf(StatEntry e) => countMode ? 1 : e.minutes;

  // ---- totals ----
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

  // ---- active days and busiest day ----
  final perDay = <DateTime, int>{};
  var total = 0;
  for (final e in list) {
    final d = DateTime(e.watchedAt.year, e.watchedAt.month, e.watchedAt.day);
    perDay[d] = (perDay[d] ?? 0) + valueOf(e);
    total += valueOf(e);
  }
  DateTime? busiestDay;
  var busiestValue = 0;
  for (final entry in perDay.entries) {
    if (entry.value > busiestValue) {
      busiestValue = entry.value;
      busiestDay = entry.key;
    }
  }
  final activeDays = perDay.length;
  final avgPerDay = activeDays == 0 ? 0 : (total / activeDays).round();

  // ---- genres, by number of different titles ----
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

  // ---- movies and series ----
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

  // ---- books ----
  var pages = 0;
  var pageBooks = 0;
  final byAuthor = <String, int>{};
  for (final e in list) {
    if (e.type != MediaType.book) continue;
    final p = e.pageCount ?? 0;
    if (p > 0) {
      pages += p;
      pageBooks++;
    }
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

  return StatsSummary(
    entries: list.length,
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
    bars: _bars(list, period, now, valueOf),
    genres: genreList.take(8).toList(),
    avgMinutes: avgMinutes,
    longestTitle: longest?.title,
    longestMinutes: longest?.minutes ?? 0,
    topTitle: topId == null ? null : titleOf[topId],
    topMinutes: topMinutes,
    pages: pages,
    avgPages: pageBooks == 0 ? 0 : (pages / pageBooks).round(),
    topAuthor: topAuthor,
    topAuthorCount: topAuthorCount,
  );
}

/// The bars of the activity chart: days, months or years, depending on the period.
List<StatBar> _bars(
    List<StatEntry> list,
    StatsPeriod period,
    DateTime now,
    int Function(StatEntry) valueOf,
    ) {
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
      final first = list.isEmpty
          ? now.year
          : list.map((e) => e.watchedAt.year).reduce(math.min);
      final count = now.year - first + 1;
      labels = [
        for (var i = 0; i < count; i++)
          "'${((first + i) % 100).toString().padLeft(2, '0')}",
      ];
      indexOf = (d) => d.year - first;
  }

  final values = List<int>.filled(labels.length, 0);
  for (final e in list) {
    final i = indexOf(e.watchedAt);
    if (i >= 0 && i < values.length) values[i] += valueOf(e);
  }
  return [for (var i = 0; i < labels.length; i++) StatBar(labels[i], values[i])];
}