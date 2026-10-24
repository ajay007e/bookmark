import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../stats/stats_provider.dart';
import 'pill_segments.dart';

/// Period selector and a card with watch time and counts.
class StatsCard extends ConsumerStatefulWidget {
  const StatsCard({super.key});

  @override
  ConsumerState<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends ConsumerState<StatsCard> {
  StatsPeriod _period = StatsPeriod.month;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stats = ref.watch(statsProvider(_period));

    return Column(
      children: [
        const SizedBox(height: 4),
        PillSegments(
          labels: [for (final p in StatsPeriod.values) p.label],
          selected: _period.index,
          onChanged: (i) => setState(() => _period = StatsPeriod.values[i]),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 190),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primaryContainer, scheme.tertiaryContainer],
              ),
            ),
            child: stats.when(
              data: (s) => _content(context, s),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Something went wrong: $e')),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => context.push('/stats?period=${_period.name}'),
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Detailed stats'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(
      BuildContext context,
      ({int minutes, int movies, int episodes, int books}) s,
      ) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final on = scheme.onPrimaryContainer;

    if (s.movies + s.episodes + s.books == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded, size: 36, color: on),
            const SizedBox(height: 12),
            Text(
              'Mark something as watched or read and your stats appear here.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: on),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _period.heading.toUpperCase(),
          style: text.labelSmall?.copyWith(
            color: on,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatDuration(s.minutes),
          style: text.displaySmall?.copyWith(
            color: on,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        Text('watch time', style: text.bodyMedium?.copyWith(color: on)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _Stat(value: s.movies, label: 'Movies', color: on)),
            Expanded(child: _Stat(value: s.episodes, label: 'Episodes', color: on)),
            Expanded(child: _Stat(value: s.books, label: 'Books', color: on)),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: text.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: text.labelMedium?.copyWith(color: color)),
      ],
    );
  }
}