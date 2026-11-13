import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../stats/stats_provider.dart';

/// Watch time and counts for one period. The pill in the corner opens a
/// sheet to change the period, tapping the card opens the detailed stats
/// for that period.
class StatsCard extends ConsumerStatefulWidget {
  const StatsCard({super.key});

  @override
  ConsumerState<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends ConsumerState<StatsCard> {
  StatsPeriod _period = StatsPeriod.week;

  static IconData _icon(StatsPeriod p) => switch (p) {
    StatsPeriod.week => Icons.view_week_outlined,
    StatsPeriod.month => Icons.calendar_view_month_outlined,
    StatsPeriod.year => Icons.calendar_today_outlined,
    StatsPeriod.all => Icons.all_inclusive_rounded,
  };

  Future<void> _pickPeriod() async {
    final picked = await showModalBottomSheet<StatsPeriod>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        final text = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text('Show stats for', style: text.titleLarge),
              ),
              for (final p in StatsPeriod.values)
                ListTile(
                  selected: p == _period,
                  selectedTileColor:
                  scheme.primaryContainer.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(_icon(p)),
                  title: Text(p.label),
                  subtitle: Text(p.heading),
                  trailing: p == _period
                      ? Icon(Icons.check_circle, color: scheme.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(p),
                ).paddedHorizontally(12),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) setState(() => _period = picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final on = scheme.onPrimaryContainer;
    final stats = ref.watch(statsProvider(_period));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/stats?period=${_period.name}'),
        child: Stack(
          children: [
            Container(
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
            Positioned(
              top: 14,
              right: 14,
              child: Material(
                color: on.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _pickPeriod,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _period.label,
                          style: text.labelLarge?.copyWith(
                            color: on,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.expand_more_rounded, size: 20, color: on),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

/// Small helper so the sheet rows have a little space on both sides.
extension on Widget {
  Widget paddedHorizontally(double v) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: v), child: this);
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