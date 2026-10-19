import 'package:drift/drift.dart' show Value;

import '../api/search_result.dart';
import '../api/tmdb_client.dart';
import 'app_database.dart';

/// Adds a search result to the local database, fetching extra details first.
class LibraryRepository {
  LibraryRepository(this._db, this._tmdb);

  final AppDatabase _db;
  final TmdbClient _tmdb;

  Future<void> add(SearchResult r, Status status) async {
    var genres = r.genres;
    int? runtime;
    bool? ongoing;
    var episodes = const <EpisodeInfo>[];

    switch (r.type) {
      case MediaType.movie:
        final basics = await _tmdb.movieBasics(r.externalId);
        genres = basics.genres;
        runtime = basics.runtime;
      case MediaType.series:
        final details = await _tmdb.seriesDetails(r.externalId);
        genres = details.genres;
        runtime = details.runtime;
        ongoing = details.ongoing;
        episodes = details.episodes;
      case MediaType.book:
        break;
    }

    await _db.addItem(MediaItemsCompanion.insert(
      type: r.type,
      externalId: r.externalId,
      title: r.title,
      posterUrl: Value(r.posterUrl),
      overview: Value(r.overview),
      year: Value(r.year),
      genres: Value(genres),
      status: Value(status),
      runtime: Value(runtime),
      ongoing: Value(ongoing),
      author: Value(r.author),
      pageCount: Value(r.pageCount),
      currentPage: Value(status == Status.done ? (r.pageCount ?? 0) : 0),
    ));

    final id = await _db.findId(r.type, r.externalId);
    if (id == null) return;

    if (r.type == MediaType.series) {
      await _db.insertEpisodes(episodes
          .map((e) => EpisodesCompanion.insert(
        seriesId: id,
        seasonNumber: e.season,
        episodeNumber: e.number,
        title: Value(e.title),
        airDate: Value(e.airDate),
        runtime: Value(e.runtime),
      ))
          .toList());

      if (status == Status.done) {
        // Added as already watched: tick every aired episode as "earlier".
        // (An ongoing series ends up as Watching, not Watched.)
        final now = DateTime.now();
        final aired = (await _db.episodesOf(id))
            .where((e) => e.airDate != null && !e.airDate!.isAfter(now));
        await _db.setEpisodesWatched(
          id,
          aired.map((e) => e.id),
          true,
          counted: false,
        );
      }
    } else if (status == Status.done) {
      await _db.addLog(id, counted: false, minutes: runtime);
    }
  }
}