import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import '../stats/stats_provider.dart';
import 'widgets/pill_segments.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _day(DateTime d) =>
    '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

/// "-" when there is no value, otherwise 1h 35m.
String _time(int minutes) => minutes == 0 ? '-' : formatDuration(minutes);

/// Detailed stats: one combined view and one for each of movies, series and books.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key, this.initialPeriod = StatsPeriod.month});

  final StatsPeriod initialPeriod;

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late StatsPeriod _period = widget.initialPeriod;
  StatsFilter _filter = StatsFilter.all;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(detailStatsProvider((period: _period, filter: _filter)));

    // Books you gave up on. Not tied to a date, so it is always "all time".
    final dropped = ref.watch(itemsByTypeProvider(MediaType.book)).maybeWhen<int>(
      data: (l) => l.where((i) => i.status == Status.dropped).length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          PillSegments(
            labels: [for (final f in StatsFilter.values) f.label],
            selected: _filter.index,
            onChanged: (i) => setState(() => _filter = StatsFilter.values[i]),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final p in StatsPeriod.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.label),
                      selected: p == _period,
                      onSelected: (_) => setState(() => _period = p),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          summary.when(
            data: (s) => _Body(
              summary: s,
              filter: _filter,
              period: _period,
              dropped: dropped,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Something went wrong: $e'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile {
  const _Tile(this.label, this.value, {this.note});

  final String label;
  final String value;
  final String? note;
}

class _Body extends StatelessWidget {
  const _Body({
    required this.summary,
    required this.filter,
    required this.period,
    required this.dropped,
  });

  final StatsSummary summary;
  final StatsFilter filter;
  final StatsPeriod period;
  final int dropped;

  List<_Tile> _tiles() {
    final s = summary;
    switch (filter) {
      case StatsFilter.all:
        return [
          _Tile('Movies', '${s.movies}'),
          _Tile('Episodes', '${s.episodes}'),
          _Tile('Books', '${s.books}'),
          _Tile('Titles', '${s.titles}'),
          _Tile('Active days', '${s.activeDays}'),
          _Tile('Avg per active day', _time(s.avgPerDay)),
        ];
      case StatsFilter.movies:
        return [
          _Tile('Movies watched', '${s.movies}'),
          _Tile('Different movies', '${s.titles}'),
          _Tile('Average length', _time(s.avgMinutes)),
          _Tile('Longest movie', _time(s.longestMinutes), note: s.longestTitle),
          _Tile('Active days', '${s.activeDays}'),
          _Tile('Avg per active day', _time(s.avgPerDay)),
        ];
      case StatsFilter.series:
        return [
          _Tile('Episodes watched', '${s.episodes}'),
          _Tile('Different series', '${s.titles}'),
          _Tile('Average episode', _time(s.avgMinutes)),
          _Tile('Most watched', _time(s.topMinutes), note: s.topTitle),
          _Tile('Active days', '${s.activeDays}'),
          _Tile('Avg per active day', _time(s.avgPerDay)),
        ];
      case StatsFilter.books:
        return [
          _Tile('Books read', '${s.books}'),
          _Tile('Different books', '${s.titles}'),
          _Tile('Pages read', s.pages == 0 ? '-' : '${s.pages}'),
          _Tile('Average pages', s.avgPages == 0 ? '-' : '${s.avgPages}'),
          _Tile(
            'Most read author',
            s.topAuthor ?? '-',
            note: s.topAuthor == null ? null : '${s.topAuthorCount} read',
          ),
          _Tile('Did not complete', '$dropped', note: 'all time'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final on = scheme.onPrimaryContainer;
    final isBooks = filter == StatsFilter.books;

    final big = isBooks ? '${s.books}' : formatDuration(s.minutes);
    final caption = isBooks
        ? (s.books == 1 ? 'book read' : 'books read')
        : 'watch time';

    final unit = switch (period) {
      StatsPeriod.week || StatsPeriod.month => 'by day',
      StatsPeriod.year => 'by month',
      StatsPeriod.all => 'by year',
    };

    final splitTotal = s.movieMinutes + s.seriesMinutes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primaryContainer, scheme.tertiaryContainer],
              ),
            ),
            child: s.entries == 0
                ? Text(
              'Nothing counted for ${period.heading.toLowerCase()} yet. '
                  'Mark something as watched or read now and it shows up here.',
              style: text.bodyMedium?.copyWith(color: on),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${filter.label} · ${period.heading}'.toUpperCase(),
                  style: text.labelSmall?.copyWith(
                    color: on,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  big,
                  style: text.displayMedium?.copyWith(
                    color: on,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Text(caption, style: text.bodyMedium?.copyWith(color: on)),
              ],
            ),
          ),

          if (s.entries > 0) ...[
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // the page scrolls
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                for (final t in _tiles())
                  _StatTile(label: t.label, value: t.value, note: t.note),
              ],
            ),

            // Activity chart
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Activity',
              subtitle: '${isBooks ? 'Books read' : 'Watch time'} $unit',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BarChart(bars: s.bars),
                  if (s.busiestDay != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Busiest day: ${_day(s.busiestDay!)} · '
                          '${isBooks ? '${s.busiestValue} read' : formatDuration(s.busiestValue)}',
                      style: text.bodySmall,
                    ),
                  ],
                ],
              ),
            ),

            // Movies vs series (combined view only)
            if (filter == StatsFilter.all && splitTotal > 0) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Movies vs series',
                subtitle: 'Share of your watch time',
                child: _SplitBar(
                  movieMinutes: s.movieMinutes,
                  seriesMinutes: s.seriesMinutes,
                ),
              ),
            ],

            // Top genres
            if (s.genres.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Top genres',
                subtitle: 'Number of different titles',
                child: Column(
                  children: [
                    for (final g in s.genres)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    g.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodyMedium,
                                  ),
                                ),
                                Text('${g.titles}', style: text.labelLarge),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: g.titles / s.genres.first.titles,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 16),
          Text(
            'Counts only what you marked as watched or read now. "Earlier" entries, '
                'and anything marked before the history feature existed, are not included.',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (note != null)
            Text(
              note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          if (subtitle != null)
            Text(
              subtitle!,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Simple bars. The tallest bar is highlighted.
class _BarChart extends StatelessWidget {
  const _BarChart({required this.bars});

  final List<StatBar> bars;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = bars.fold<int>(0, (m, b) => b.value > m ? b.value : m);
    final gap = bars.length > 20 ? 1.0 : 3.0;

    double factor(int v) {
      if (maxValue == 0 || v == 0) return 0.02; // a thin stub for empty bars
      return (v / maxValue).clamp(0.05, 1.0).toDouble();
    }

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in bars)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: Column(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: factor(b.value),
                          widthFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: (maxValue > 0 && b.value == maxValue)
                                  ? scheme.primary
                                  : scheme.primary.withValues(alpha: 0.35),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 14,
                      child: Center(
                        child: Text(
                          b.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One bar split into movies and series, with the share under it.
class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.movieMinutes, required this.seriesMinutes});

  final int movieMinutes;
  final int seriesMinutes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final total = movieMinutes + seriesMinutes;
    final moviePct = (movieMinutes * 100 / total).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                if (movieMinutes > 0)
                  Expanded(
                    flex: movieMinutes,
                    child: ColoredBox(color: scheme.primary),
                  ),
                if (seriesMinutes > 0)
                  Expanded(
                    flex: seriesMinutes,
                    child: ColoredBox(color: scheme.tertiary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Dot(color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              'Movies ${formatDuration(movieMinutes)} · $moviePct%',
              style: text.bodySmall,
            ),
            const Spacer(),
            _Dot(color: scheme.tertiary),
            const SizedBox(width: 6),
            Text(
              'Series ${formatDuration(seriesMinutes)} · ${100 - moviePct}%',
              style: text.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}