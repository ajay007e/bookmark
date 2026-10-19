import 'package:flutter/material.dart';

import '../../api/detail_info.dart';
import '../../data/app_database.dart';
import '../series_actions.dart';
import 'poster_card.dart';
import 'score_badge.dart';

/// poster | Season n            5/10
///        | rating · year · n episodes
///        | overview or details
/// A fixed-size card for the season strip on the Episodes tab.
class SeasonCard extends StatelessWidget {
  const SeasonCard({
    super.key,
    required this.season,
    required this.episodes,
    this.info,
    required this.selected,
    required this.onTap,
  });

  static const width = 300.0;
  static const height = 140.0;

  final int season;
  final List<Episode> episodes; // this season's episodes from the database
  final SeasonInfo? info; // from TMDB, null while loading or offline
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    final count = episodes.isNotEmpty ? episodes.length : (info?.episodeCount ?? 0);
    final watched = episodes.where((e) => e.watched).length;
    final aired = episodes.where((e) => isAired(e, now)).length;
    final year = info?.airDate?.year ??
        episodes.map((e) => e.airDate).whereType<DateTime>().firstOrNull?.year;
    final score = info?.voteAverage;
    final overview = info?.overview;

    final meta = [
      if (year != null) '$year',
      if (count > 0) '$count episode${count == 1 ? '' : 's'}',
    ].join(' · ');
    final detail = (overview != null && overview.isNotEmpty)
        ? overview
        : (episodes.isEmpty ? '' : 'Aired $aired of $count episodes.');

    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? scheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(
                  height: height - 16,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: PosterImage(
                        type: MediaType.series,
                        title: 'Season $season',
                        url: info?.posterUrl,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Season $season', style: text.titleMedium)),
                          if (episodes.isNotEmpty)
                            Text('$watched/$count', style: text.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (score != null) ...[
                            ScoreBadge(value: score, outOf: 10, size: 26),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: detail.isEmpty
                            ? const SizedBox.shrink()
                            : Text(
                          detail,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                      ),
                      if (episodes.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            value: count == 0 ? 0 : watched / count,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}