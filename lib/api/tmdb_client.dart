import 'package:dio/dio.dart';

import '../config/secrets.dart';
import '../data/app_database.dart';
import 'search_result.dart';

class TmdbClient {
  TmdbClient([Dio? dio])
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        queryParameters: {'api_key': tmdbApiKey},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ));

  final Dio _dio;

  static String? _poster(String? path) =>
      path == null ? null : 'https://image.tmdb.org/t/p/w342$path';

  static int? _year(String? date) => (date != null && date.length >= 4)
      ? int.tryParse(date.substring(0, 4))
      : null;

  static String _genreNames(dynamic genres) =>
      ((genres as List?) ?? const []).map((g) => (g as Map)['name']).join(',');

  /// Search movies or series by title.
  Future<List<SearchResult>> search(MediaType type, String query) async {
    final isMovie = type == MediaType.movie;
    final res = await _dio.get(
      isMovie ? '/search/movie' : '/search/tv',
      queryParameters: {'query': query, 'include_adult': false},
    );
    final results = (res.data['results'] as List).cast<Map<String, dynamic>>();
    return results.map((m) {
      final date = (isMovie ? m['release_date'] : m['first_air_date']) as String?;
      return SearchResult(
        type: type,
        externalId: '${m['id']}',
        title: ((isMovie ? m['title'] : m['name']) as String?) ?? 'Untitled',
        year: _year(date),
        posterUrl: _poster(m['poster_path'] as String?),
        overview: m['overview'] as String?,
      );
    }).toList();
  }

  Future<String> movieGenres(String id) async {
    final res = await _dio.get('/movie/$id');
    return _genreNames(res.data['genres']);
  }

  /// Genres plus every episode of every season (specials are skipped).
  Future<SeriesDetails> seriesDetails(String id) async {
    final res = await _dio.get('/tv/$id');
    final genres = _genreNames(res.data['genres']);

    final seasonNumbers = (res.data['seasons'] as List)
        .map((s) => (s as Map)['season_number'] as int)
        .where((n) => n > 0)
        .toList();

    final responses = await Future.wait(
      seasonNumbers.map((n) async => MapEntry(n, await _dio.get('/tv/$id/season/$n'))),
    );

    final episodes = <EpisodeInfo>[];
    for (final entry in responses) {
      final list = (entry.value.data['episodes'] as List?) ?? const [];
      for (final e in list.cast<Map<String, dynamic>>()) {
        final air = e['air_date'] as String?;
        episodes.add(EpisodeInfo(
          season: entry.key,
          number: e['episode_number'] as int,
          title: e['name'] as String?,
          airDate: (air == null || air.isEmpty) ? null : DateTime.tryParse(air),
        ));
      }
    }
    return SeriesDetails(genres: genres, episodes: episodes);
  }
}