import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/detail_info.dart';
import '../data/app_database.dart';
import '../providers.dart';
import 'format.dart';
import 'widgets/cast_row.dart';
import 'widgets/credit_block.dart';
import 'widgets/detail_header.dart';
import 'widgets/load_note.dart';
import 'widgets/meta_block.dart';
import 'widgets/section_divider.dart';
import 'widgets/similar_row.dart';
import 'widgets/title_row.dart';
import 'widgets/watch_now.dart';
import 'widgets/watch_tick.dart';

class MovieDetailView extends ConsumerWidget {
  const MovieDetailView({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final info = ref.watch(movieInfoProvider(item.externalId));
    final loaded = info.maybeWhen<MovieInfo?>(data: (i) => i, orElse: () => null);

    // Older movies get their runtime saved the first time details load.
    ref.listen<AsyncValue<MovieInfo>>(movieInfoProvider(item.externalId), (_, next) {
      final runtime = next.maybeWhen<int?>(data: (i) => i.runtime, orElse: () => null);
      if (runtime != null && item.runtime == null) {
        ref.read(databaseProvider).saveMeta(item.id, runtime: runtime);
      }
    });

    final runtime = loaded?.runtime ?? item.runtime;
    final certification = loaded?.certification;
    final release = loaded?.releaseDate;
    final country = loaded?.releaseCountry;
    final language = loaded?.language;
    final status = loaded?.status;
    final score = loaded?.voteAverage;
    final hasScore = score != null && score > 0 && (loaded?.voteCount ?? 0) > 0;
    final tagline = loaded?.tagline;
    final directors = loaded?.directors ?? const <String>[];
    final writers = loaded?.writers ?? const <String>[];
    final cast = loaded?.cast ?? const <CastMember>[];
    final similar = loaded?.similar ?? const [];

    final line1 = [
      if (certification != null) certification,
      if (runtime != null) formatMinutes(runtime),
    ].join(' · ');
    final line2 = [
      if (release != null)
        (country == null ? formatDate(release) : '${formatDate(release)} ($country)'),
      if (language != null) language,
      if (status != null) status,
    ].join(' · ');

    final genres = item.genres.isEmpty ? <String>[] : item.genres.split(',');
    final overview = item.overview;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailHeader(item: item),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleRow(
                    title: item.title,
                    year: item.year,
                    trailing: WatchTick(item: item),
                  ),
                  const SizedBox(height: 12),
                  MetaBlock(score: hasScore ? score : null, lines: [line1, line2]),
                  if (genres.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final g in genres)
                          Chip(label: Text(g), visualDensity: VisualDensity.compact),
                      ],
                    ),
                  ],
                  // WatchNowSection(options: loaded?.watch),
                  if (tagline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        tagline,
                        style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  if (overview != null && overview.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Overview', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(overview, style: text.bodyLarge),
                  ],
                  LoadNote(state: info, what: 'cast and ratings'),
                  if (directors.isNotEmpty || writers.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (directors.isNotEmpty)
                          Expanded(
                            child: CreditBlock(
                              label: directors.length == 1 ? 'Director' : 'Directors',
                              names: directors,
                            ),
                          ),
                        if (writers.isNotEmpty)
                          Expanded(
                            child: CreditBlock(
                              label: writers.length == 1 ? 'Writer' : 'Writers',
                              names: writers,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (cast.isNotEmpty) ...[
                    const SectionDivider(),
                    Text('Cast', style: text.titleMedium),
                    const SizedBox(height: 8),
                    CastRow(cast: cast),
                  ],
                  if (similar.isNotEmpty) ...[
                    const SectionDivider(bottom: 0),
                    SimilarRow(type: MediaType.movie, items: similar),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}