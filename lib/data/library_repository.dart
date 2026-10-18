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
    var episodes = const <EpisodeInfo>[];

    switch (r.type) {
      case MediaType.movie:
        genres = await _tmdb.movieGenres(r.externalId);
      case MediaType.series:
        final details = await _tmdb.seriesDetails(r.externalId);
        genres = details.genres;
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
      author: Value(r.author),
      pageCount: Value(r.pageCount),
      currentPage: Value(status == Status.done ? (r.pageCount ?? 0) : 0),
    ));

    if (episodes.isEmpty) return;
    final id = await _db.findId(r.type, r.externalId);
    if (id == null) return;

    final now = DateTime.now();
    await _db.insertEpisodes(episodes.map((e) {
      final aired = e.airDate != null && !e.airDate!.isAfter(now);
      final watched = status == Status.done && aired;
      return EpisodesCompanion.insert(
        seriesId: id,
        seasonNumber: e.season,
        episodeNumber: e.number,
        title: Value(e.title),
        airDate: Value(e.airDate),
        watched: Value(watched),
        watchedAt: Value(watched ? now : null),
      );
    }).toList());
  }
}