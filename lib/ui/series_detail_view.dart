import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/detail_info.dart';
import '../data/app_database.dart';
import '../providers.dart';
import 'series_actions.dart';
import 'widgets/cast_row.dart';
import 'widgets/detail_header.dart';
import 'widgets/episode_tile.dart';
import 'widgets/load_note.dart';
import 'widgets/score_badge.dart';
import 'widgets/season_button.dart';
import 'widgets/similar_row.dart';
import 'widgets/status_menu.dart';

class SeriesDetailView extends ConsumerWidget {
  const SeriesDetailView({super.key, required this.item});

  final MediaItem item;

  static const _choices = [Status.want, Status.inProgress, Status.done];

  static String _runtime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String? _statusText(String? s) => switch (s) {
    null => null,
    'Returning Series' => 'Ongoing',
    'Ended' => 'Ended',
    'Canceled' => 'Canceled',
    _ => s,
  };

  /// Status picked from the dropdown. Episodes follow the status.
  Future<void> _pickStatus(
      BuildContext context,
      WidgetRef ref,
      Status s,
      List<Episode> eps,
      ) async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();

    switch (s) {
      case Status.inProgress:
        await db.setStatus(item.id, s);
      case Status.want:
        if (eps.any((e) => e.watched)) {
          final ok = await confirmDialog(
            context,
            title: 'Back to Want to watch?',
            message: 'All watched episodes will be unticked.',
            yes: 'Clear and move',
          );
          if (ok) await db.clearSeriesProgress(item.id);
        } else {
          await db.setStatus(item.id, s);
        }
      case Status.done:
        final todo = eps.where((e) => !e.watched && isAired(e, now)).toList();
        if (todo.isNotEmpty) {
          final ok = await confirmDialog(
            context,
            title: 'Mark as Watched?',
            message:
            '${todo.length} aired episode${todo.length == 1 ? '' : 's'} will be marked as watched.',
            yes: 'Mark all',
          );
          if (ok) await db.setEpisodesWatched(item.id, todo.map((e) => e.id), true);
        } else if (eps.any((e) => e.watched)) {
          await db.setStatus(item.id, s);
        } else {
          messenger.showSnackBar(const SnackBar(
            content: Text('Nothing has aired yet, so there is nothing to mark.'),
          ));
        }
      case Status.dropped:
        break;
    }
  }

  void _showSeasons(BuildContext context, List<int> seasons, List<Episode> eps) {
    final router = GoRouter.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Seasons', style: Theme.of(sheetContext).textTheme.titleLarge),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final n in seasons.reversed)
                    _seasonTile(sheetContext, router, n, eps),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seasonTile(
      BuildContext sheetContext,
      GoRouter router,
      int n,
      List<Episode> eps,
      ) {
    final inSeason = eps.where((e) => e.seasonNumber == n).toList();
    final done = inSeason.where((e) => e.watched).length;
    return ListTile(
      title: Text('Season $n'),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: LinearProgressIndicator(
          value: inSeason.isEmpty ? 0 : done / inSeason.length,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$done/${inSeason.length}'),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        Navigator.of(sheetContext).pop();
        router.push('/item/${item.id}/season/$n');
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final db = ref.read(databaseProvider);

    final info = ref.watch(seriesInfoProvider(item.externalId));
    final loaded = info.maybeWhen<SeriesInfo?>(data: (i) => i, orElse: () => null);
    final eps = ref
        .watch(episodesProvider(item.id))
        .maybeWhen<List<Episode>>(data: (l) => l, orElse: () => const <Episode>[]);

    final now = DateTime.now();
    final seasons = eps.map((e) => e.seasonNumber).toSet().toList()..sort();
    final latest = seasons.isEmpty ? null : seasons.last;
    final latestEps = eps.where((e) => e.seasonNumber == latest).toList();
    final airedCount = eps.where((e) => isAired(e, now)).length;
    final watchedCount = eps.where((e) => e.watched).length;

    final score = loaded?.voteAverage;
    final hasScore = score != null && score > 0 && (loaded?.voteCount ?? 0) > 0;
    final runtime = loaded?.runtime;
    final certification = loaded?.certification;
    final tagline = loaded?.tagline;
    final creators = loaded?.creators ?? const <String>[];
    final cast = loaded?.cast ?? const <CastMember>[];

    final meta = [
      if (item.year != null) '${item.year}',
      if (runtime != null) _runtime(runtime),
      if (certification != null) certification,
    ].join(' · ');
    final seasonLine = [
      if (seasons.isNotEmpty) '${seasons.length} season${seasons.length == 1 ? '' : 's'}',
      if (_statusText(loaded?.status) != null) _statusText(loaded?.status)!,
    ].join(' · ');

    final genres = item.genres.isEmpty ? <String>[] : item.genres.split(',');
    final overview = item.overview;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailHeader(item: item),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(item.title, style: text.headlineMedium)),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: StatusMenuButton(
                          item: item,
                          choices: _choices,
                          onStatus: (s) => _pickStatus(context, ref, s, eps),
                        ),
                      ),
                    ],
                  ),
                  if (hasScore || meta.isNotEmpty || seasonLine.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          if (hasScore) ...[
                            ScoreBadge(value: score, outOf: 10),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (meta.isNotEmpty) Text(meta, style: text.bodyLarge),
                                if (seasonLine.isNotEmpty)
                                  Text(seasonLine, style: text.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (tagline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        tagline,
                        style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  if (genres.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final g in genres)
                          Chip(label: Text(g), visualDensity: VisualDensity.compact),
                      ],
                    ),
                  ],

                  // ---------- Episode tracker ----------
                  if (eps.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      airedCount == 0
                          ? 'Nothing has aired yet'
                          : '$watchedCount of $airedCount aired episodes watched',
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: airedCount == 0
                            ? 0
                            : (watchedCount / airedCount).clamp(0.0, 1.0),
                      ),
                    ),
                  ],
                  if (latest != null) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Text('Season $latest', style: text.titleLarge)),
                        Text(
                          '${latestEps.where((e) => e.watched).length}/${latestEps.length}',
                          style: text.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SeasonButton(seriesId: item.id, all: eps, season: latestEps),
                    for (final e in latestEps)
                      EpisodeTile(
                        episode: e,
                        onChanged: (v) {
                          if (v) {
                            tickEpisodes(
                              context,
                              ref,
                              seriesId: item.id,
                              all: eps,
                              targets: [e],
                            );
                          } else {
                            db.setEpisodesWatched(item.id, [e.id], false);
                          }
                        },
                      ),
                    if (seasons.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton.icon(
                          onPressed: () => _showSeasons(context, seasons, eps),
                          icon: const Icon(Icons.list),
                          label: const Text('More seasons'),
                        ),
                      ),
                  ],
                  if (eps.isEmpty) ...[
                    const SizedBox(height: 20),
                    Text('No episodes were saved for this series.', style: text.bodyMedium),
                  ],

                  // ---------- Info from TMDB ----------
                  if (overview != null && overview.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Overview', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(overview, style: text.bodyLarge),
                  ],
                  LoadNote(state: info, what: 'cast and ratings'),
                  if (creators.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Created by', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(creators.join(', '), style: text.bodyLarge),
                  ],
                  if (cast.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Cast', style: text.titleMedium),
                    const SizedBox(height: 8),
                    CastRow(cast: cast),
                  ],
                  SimilarRow(type: MediaType.series, items: loaded?.similar ?? const []),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}