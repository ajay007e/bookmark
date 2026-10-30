import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import '../draft_item.dart';
import '../draft_series.dart';
import '../watch_actions.dart';

/// The round "more" button on every detail page. It opens the same options
/// as a long press on the tick. For series it is where the whole-series
/// options live (add to list, mark all aired episodes, mark all unwatched, remove).
class ItemMenuButton extends ConsumerWidget {
  const ItemMenuButton({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Episode> episodes = item.type != MediaType.series
        ? const <Episode>[]
        : (item.isDraft
        ? ref.watch(draftEpisodesProvider(item.externalId))
        : ref.watch(episodesProvider(item.id)))
        .maybeWhen<List<Episode>>(
      data: (l) => l,
      orElse: () => const <Episode>[],
    );

    return Padding(
      padding: const EdgeInsets.all(6),
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
        ),
        tooltip: 'More',
        icon: const Icon(Icons.more_vert),
        onPressed: () => showWatchMenu(context, ref, item, episodes),
      ),
    );
  }
}