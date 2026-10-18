import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'series_actions.dart';
import 'widgets/episode_tile.dart';
import 'widgets/season_button.dart';

/// Every episode of one season, as a checklist.
class SeasonScreen extends ConsumerWidget {
  const SeasonScreen({super.key, required this.seriesId, required this.season});

  final int seriesId;
  final int season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final db = ref.read(databaseProvider);

    final title = ref
        .watch(itemProvider(seriesId))
        .maybeWhen<String>(data: (i) => i?.title ?? '', orElse: () => '');
    final eps = ref
        .watch(episodesProvider(seriesId))
        .maybeWhen<List<Episode>>(data: (l) => l, orElse: () => const <Episode>[]);

    final inSeason = eps.where((e) => e.seasonNumber == season).toList();
    final done = inSeason.where((e) => e.watched).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Season $season'),
            if (title.isNotEmpty) Text(title, style: text.labelMedium),
          ],
        ),
      ),
      body: inSeason.isEmpty
          ? const Center(child: Text('No episodes in this season'))
          : ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('$done of ${inSeason.length} watched', style: text.titleSmall),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: done / inSeason.length,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SeasonButton(seriesId: seriesId, all: eps, season: inSeason),
          ),
          const SizedBox(height: 8),
          for (final e in inSeason)
            EpisodeTile(
              episode: e,
              onChanged: (v) {
                if (v) {
                  tickEpisodes(
                    context,
                    ref,
                    seriesId: seriesId,
                    all: eps,
                    targets: [e],
                  );
                } else {
                  db.setEpisodesWatched(seriesId, [e.id], false);
                }
              },
            ),
        ],
      ),
    );
  }
}