import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/detail_info.dart';
import '../../data/app_database.dart';
import '../format.dart';
import '../series_actions.dart';
import 'score_badge.dart';
import 'tick_circle.dart';

/// image | n. title / rating · date · runtime / description | tick
/// Tap the text to expand a long description. Tap the tick to mark it.
class EpisodeCard extends StatefulWidget {
  const EpisodeCard({
    super.key,
    required this.episode,
    this.detail,
    required this.onToggle,
  });

  final Episode episode; // from the database (watched or not)
  final EpisodeDetail? detail; // from TMDB, null while loading or offline
  final ValueChanged<bool> onToggle; // true = mark watched, false = unmark

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final e = widget.episode;
    final d = widget.detail;

    final aired = isAired(e, DateTime.now());
    final air = e.airDate ?? d?.airDate;
    final minutes = d?.runtime ?? e.runtime;
    final score = d?.voteAverage;
    final title = d?.title ?? e.title ?? 'Episode ${e.episodeNumber}';
    final overview = d?.overview ?? '';
    final still = d?.stillUrl;

    final dateText = air == null
        ? 'Air date not announced'
        : (aired ? formatDate(air) : 'Airs ${formatDate(air)}');
    final meta = [dateText, if (minutes != null) formatMinutes(minutes)].join(' · ');

    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.tv, color: scheme.onSurfaceVariant),
    );

    return InkWell(
      onTap: overview.isEmpty ? null : () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Opacity(
                opacity: aired ? 1 : 0.55,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: still == null
                              ? placeholder
                              : CachedNetworkImage(
                            imageUrl: still,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => placeholder,
                            errorWidget: (_, _, _) => placeholder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.episodeNumber}. $title',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (score != null) ...[
                                ScoreBadge(value: score, outOf: 10, size: 26),
                                const SizedBox(width: 6),
                              ],
                              Flexible(child: Text(meta, style: text.bodySmall)),
                            ],
                          ),
                          if (overview.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                overview,
                                maxLines: _open ? null : 3,
                                overflow: _open
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: text.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: TickCircle(
                state: e.watched ? TickState.done : TickState.none,
                size: 36,
                // Episodes that have not aired cannot be ticked.
                onTap: aired ? () => widget.onToggle(!e.watched) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}