import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import '../series_actions.dart';

class SeasonButton extends ConsumerWidget {
  const SeasonButton({
    super.key,
    required this.seriesId,
    required this.all,
    required this.season,
  });

  final int seriesId;
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
        onPressed: () => tickEpisodes(
          context,
          ref,
          seriesId: seriesId,
          all: all,
          targets: todo,
        ),
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
        if (ok) await db.setEpisodesWatched(seriesId, watched.map((e) => e.id), false);
      },
      icon: const Icon(Icons.undo),
      label: const Text('Mark season as unwatched'),
    );
  }
}