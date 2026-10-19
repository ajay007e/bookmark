import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/detail_info.dart';
import '../data/app_database.dart';
import '../providers.dart';
import 'series_actions.dart';
import 'widgets/cast_row.dart';
import 'widgets/credit_block.dart';
import 'widgets/detail_header.dart';
import 'widgets/episode_card.dart';
import 'widgets/load_note.dart';
import 'widgets/meta_block.dart';
import 'widgets/season_button.dart';
import 'widgets/season_card.dart';
import 'widgets/section_divider.dart';
import 'widgets/similar_row.dart';
import 'widgets/title_row.dart';
import 'widgets/watch_now.dart';
import 'widgets/watch_tick.dart';

class SeriesDetailView extends ConsumerStatefulWidget {
  const SeriesDetailView({super.key, required this.item});

  final MediaItem item;

  @override
  ConsumerState<SeriesDetailView> createState() => _SeriesDetailViewState();
}

class _SeriesDetailViewState extends ConsumerState<SeriesDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _strip = ScrollController(); // the season cards
  final _list = ScrollController(); // the episodes
  final _targetKey = GlobalKey(); // the last watched episode

  int? _season; // null = the season of the last watched episode
  bool _focusPending = false;

  MediaItem get item => widget.item;

  @override
  void dispose() {
    _tabs.dispose();
    _strip.dispose();
    _list.dispose();
    super.dispose();
  }

  static int _order(Episode e) => e.seasonNumber * 10000 + e.episodeNumber;

  /// The furthest episode you have ticked.
  static Episode? _lastWatched(List<Episode> eps) {
    Episode? best;
    for (final e in eps) {
      if (!e.watched) continue;
      if (best == null || _order(e) > _order(best)) best = e;
    }
    return best;
  }

  static String? _statusText(String? s) => switch (s) {
    null => null,
    'Returning Series' => 'Ongoing',
    'Ended' => 'Ended',
    'Canceled' => 'Canceled',
    _ => s,
  };

  void _onTab(int index) {
    setState(() {
      if (index == 1) {
        _season = null; // back to the last watched season
        _focusPending = true;
      }
    });
  }

  /// Brings a season card to the left edge of the strip.
  void _focusStrip(int index) {
    if (!_strip.hasClients) return;
    final max = _strip.position.maxScrollExtent;
    _strip.jumpTo((index * (SeasonCard.width + 12)).clamp(0.0, max).toDouble());
  }

  /// Puts the last watched episode at the top of the list, or the first
  /// episode when [toLast] is false.
  void _focusList({required bool toLast}) {
    final ctx = toLast ? _targetKey.currentContext : null;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, alignment: 0, duration: Duration.zero);
    } else if (_list.hasClients) {
      _list.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(seriesInfoProvider(item.externalId));
    final loaded = info.maybeWhen<SeriesInfo?>(data: (i) => i, orElse: () => null);
    final eps = ref
        .watch(episodesProvider(item.id))
        .maybeWhen<List<Episode>>(data: (l) => l, orElse: () => const <Episode>[]);

    // Older series get their runtime and "still running" flag saved here.
    ref.listen<AsyncValue<SeriesInfo>>(seriesInfoProvider(item.externalId), (_, next) {
      final i = next.maybeWhen<SeriesInfo?>(data: (v) => v, orElse: () => null);
      if (i == null) return;
      final newRuntime = (item.runtime == null && i.runtime != null) ? i.runtime : null;
      final newOngoing = (i.ongoing != null && i.ongoing != item.ongoing) ? i.ongoing : null;
      if (newRuntime != null || newOngoing != null) {
        ref.read(databaseProvider).saveMeta(item.id, runtime: newRuntime, ongoing: newOngoing);
      }
    });

    final tabBar = TabBar(
      controller: _tabs,
      onTap: _onTab,
      dividerColor: Colors.transparent,
      tabs: const [Tab(text: 'Details'), Tab(text: 'Episodes')],
    );

    return _tabs.index == 1
        ? _episodesPage(context, tabBar, loaded, eps)
        : _detailsPage(context, tabBar, info, loaded, eps);
  }

  // ---------- Details tab ----------

  Widget _detailsPage(
      BuildContext context,
      TabBar tabBar,
      AsyncValue<SeriesInfo> info,
      SeriesInfo? loaded,
      List<Episode> eps,
      ) {
    final text = Theme.of(context).textTheme;

    final score = loaded?.voteAverage;
    final hasScore = score != null && score > 0 && (loaded?.voteCount ?? 0) > 0;
    final tagline = loaded?.tagline;
    final creators = loaded?.creators ?? const <String>[];
    final cast = loaded?.cast ?? const <CastMember>[];
    final similar = loaded?.similar ?? const [];

    final line1 = loaded?.certification ?? '';
    final line2 = [
      if (loaded?.language != null) loaded!.language!,
      if (_statusText(loaded?.status) != null) _statusText(loaded?.status)!,
    ].join(' · ');

    final genres = item.genres.isEmpty ? <String>[] : item.genres.split(',');
    final overview = item.overview;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailHeader(item: item, bottom: tabBar),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleRow(
                    title: item.title,
                    year: item.year,
                    trailing: WatchTick(item: item, episodes: eps),
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
                  if (creators.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    CreditBlock(
                      label: creators.length == 1 ? 'Creator' : 'Creators',
                      names: creators,
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
                    SimilarRow(type: MediaType.series, items: similar),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Episodes tab ----------

  Widget _episodesPage(
      BuildContext context,
      TabBar tabBar,
      SeriesInfo? loaded,
      List<Episode> eps,
      ) {
    final text = Theme.of(context).textTheme;
    final db = ref.read(databaseProvider);

    final seasons = eps.map((e) => e.seasonNumber).toSet().toList()..sort();
    final last = _lastWatched(eps);
    final shown =
        _season ?? last?.seasonNumber ?? (seasons.isEmpty ? null : seasons.first);
    final inSeason = eps.where((e) => e.seasonNumber == shown).toList();
    final done = inSeason.where((e) => e.watched).length;
    // The last watched episode only gets its key in the season it belongs to.
    final targetId = (last != null && last.seasonNumber == shown) ? last.id : null;

    // Posters, episode images, ratings and descriptions for the shown season.
    SeasonDetail? detail;
    if (shown != null) {
      final key = (tmdbId: item.externalId, season: shown);
      detail = ref
          .watch(seasonDetailProvider(key))
          .maybeWhen<SeasonDetail?>(data: (d) => d, orElse: () => null);

      // Older series saved no episode runtimes. Fill them in once TMDB answers.
      ref.listen<AsyncValue<SeasonDetail>>(seasonDetailProvider(key), (_, state) {
        final d = state.maybeWhen<SeasonDetail?>(data: (v) => v, orElse: () => null);
        if (d == null) return;
        final missing =
        eps.any((e) => e.seasonNumber == key.season && e.runtime == null);
        if (!missing) return;
        final runtimes = {
          for (final entry in d.episodes.entries)
            if (entry.value.runtime != null) entry.key: entry.value.runtime!,
        };
        db.fillEpisodeRuntimes(item.id, key.season, runtimes);
      });
    }

    // When the tab opens: show the last watched season and episode at the top.
    if (_focusPending && eps.isNotEmpty) {
      _focusPending = false;
      final index = seasons.indexOf(shown ?? -1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusStrip(index < 0 ? 0 : index);
        _focusList(toLast: targetId != null);
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const RoundBackButton(),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: tabBar,
      ),
      body: eps.isEmpty
          ? const Center(child: Text('No episodes were saved for this series.'))
          : Column(
        children: [
          // The season cards stay here. Only the episodes scroll.
          SizedBox(
            height: SeasonCard.height + 16,
            child: ListView.separated(
              controller: _strip,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: seasons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final s = seasons[i];
                return SeasonCard(
                  season: s,
                  episodes: eps.where((e) => e.seasonNumber == s).toList(),
                  info: loaded?.seasons.where((x) => x.number == s).firstOrNull,
                  selected: s == shown,
                  onTap: () {
                    setState(() => _season = s);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _focusList(toLast: last != null && last.seasonNumber == s);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: _list,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Episodes ${inSeason.length}',
                          style: text.titleMedium,
                        ),
                      ),
                      if (inSeason.isNotEmpty)
                        Text('$done/${inSeason.length}', style: text.titleSmall),
                    ],
                  ),
                  if (inSeason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: done / inSeason.length,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SeasonButton(seriesId: item.id, all: eps, season: inSeason),
                    const SizedBox(height: 4),
                  ],
                  for (final e in inSeason) ...[
                    EpisodeCard(
                      key: e.id == targetId ? _targetKey : ValueKey(e.id),
                      episode: e,
                      detail: detail?.episodes[e.episodeNumber],
                      onToggle: (watched) {
                        if (watched) {
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
                    const Divider(height: 1),
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