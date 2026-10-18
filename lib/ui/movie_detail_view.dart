import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/detail_info.dart';
import '../data/app_database.dart';
import '../providers.dart';
import 'widgets/cast_row.dart';
import 'widgets/detail_header.dart';
import 'widgets/load_note.dart';
import 'widgets/similar_row.dart';
import 'widgets/score_badge.dart';
import 'widgets/status_menu.dart';

class MovieDetailView extends ConsumerWidget {
  const MovieDetailView({super.key, required this.item});

  final MediaItem item;

  static const _choices = [Status.want, Status.inProgress, Status.done];

  static String _runtime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final info = ref.watch(movieInfoProvider(item.externalId));
    final loaded =
    info.maybeWhen<MovieInfo?>(data: (i) => i, orElse: () => null);

    final runtime = loaded?.runtime;
    final certification = loaded?.certification;
    final score = loaded?.voteAverage;
    final hasScore = score != null && score > 0 && (loaded?.voteCount ?? 0) > 0;
    final tagline = loaded?.tagline;
    final directors = loaded?.directors ?? const <String>[];
    final cast = loaded?.cast ?? const <CastMember>[];

    final meta = [
      if (item.year != null) '${item.year}',
      if (runtime != null) _runtime(runtime),
      if (certification != null) certification,
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
                        child: StatusMenuButton(item: item, choices: _choices),
                      ),
                    ],
                  ),
                  if (hasScore || meta.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          if (hasScore) ...[
                            ScoreBadge(value: score, outOf: 10),
                            const SizedBox(width: 12),
                          ],
                          Expanded(child: Text(meta, style: text.bodyLarge)),
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
                  if (overview != null && overview.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Overview', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(overview, style: text.bodyLarge),
                  ],
                  LoadNote(state: info, what: 'cast and ratings'),
                  if (directors.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      directors.length == 1 ? 'Director' : 'Directors',
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(directors.join(', '), style: text.bodyLarge),
                  ],
                  if (cast.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Cast', style: text.titleMedium),
                    const SizedBox(height: 8),
                    CastRow(cast: cast),
                  ],
                  SimilarRow(type: MediaType.movie, items: loaded?.similar ?? const []),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}