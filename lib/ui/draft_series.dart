import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';

/// The episodes of a series that is not saved yet, fetched from TMDB.
/// They have negative ids, which no saved episode ever has.
final draftEpisodesProvider = FutureProvider.family<List<Episode>, String>(
      (ref, tmdbId) async {
    final details = await ref.watch(tmdbProvider).seriesDetails(tmdbId);
    return [
      for (final e in details.episodes)
        Episode(
          id: -(e.season * 10000 + e.number) - 1,
          seriesId: -1,
          seasonNumber: e.season,
          episodeNumber: e.number,
          title: e.title,
          airDate: e.airDate,
          runtime: e.runtime,
          watched: false,
          watchedAt: null,
        ),
    ];
  },
  retry: (count, error) => null,
);