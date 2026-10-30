import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import '../series_actions.dart';

/// Tap = mark the season watched now. Long press = choose now or earlier.
class SeasonButton extends ConsumerWidget {
  const SeasonButton({
    super.key,
    required this.series,
    required this.all,
    required this.season,
  });

  final MediaItem series;
  final List<Episode> all; // every episode of the series
  final List<Episode> season; // only this season's episodes

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final todo = season.where((e) => !e.watched && isAired(e, now)).toList();
    final watched = season.where((e) => e.watched).toList();

    if (todo.isEmpty && watched.isEmpty) return const SizedBox.shrink();

    if (todo.isNotEmpty) {
      return FilledButton.tonalIcon(
        onPressed: () => markEpisodes(
          context,
          ref,
          series: series,
          all: all,
          targets: todo,
        ),
        onLongPress: () async {
          final n = todo.length;
          final counted = await askNowOrEarlier(
            context,
            title: 'Mark $n episode${n == 1 ? '' : 's'} as watched',
          );
          if (counted == null || !context.mounted) return;
          await markEpisodes(
            context,
            ref,
            series: series,
            all: all,
            targets: todo,
            counted: counted,
          );
        },
        icon: const Icon(Icons.done_all),
        label: const Text('Mark season as watched'),
      );
    }

    return OutlinedButton.icon(
      onPressed: () async {
        final db = ref.read(databaseProvider);
        final ok = await confirmDialog(
          context,
          title: 'Mark season as unwatched?',
          message: 'All ${watched.length} watched episodes in this season will be unticked.',
          yes: 'Unmark',
        );
        if (ok) await db.setEpisodesWatched(series.id, watched.map((e) => e.id), false);
      },
      icon: const Icon(Icons.undo),
      label: const Text('Mark season as unwatched'),
    );
  }
}