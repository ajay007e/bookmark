import 'package:dio/dio.dart';

import '../config/secrets.dart';
import '../data/app_database.dart';
import 'detail_info.dart';
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

  static String? _profile(String? path) =>
      path == null ? null : 'https://image.tmdb.org/t/p/w185$path';

  static int? _year(String? date) => (date != null && date.length >= 4)
      ? int.tryParse(date.substring(0, 4))
      : null;

  static String _genreNames(dynamic genres) =>
      ((genres as List?) ?? const []).map((g) => (g as Map)['name']).join(',');

  /// One movie or series entry (search result or recommendation) to a SearchResult.
  static SearchResult _toResult(Map<String, dynamic> m, MediaType type) {
    final isMovie = type == MediaType.movie;
    final date = (isMovie ? m['release_date'] : m['first_air_date']) as String?;
    return SearchResult(
      type: type,
      externalId: '${m['id']}',
      title: ((isMovie ? m['title'] : m['name']) as String?) ?? 'Untitled',
      year: _year(date),
      posterUrl: _poster(m['poster_path'] as String?),
      overview: m['overview'] as String?,
    );
  }

  /// TMDB's "recommendations" block, keeping only entries that have a poster.
  static List<SearchResult> _similar(dynamic recommendations, MediaType type) {
    final results = ((recommendations as Map?)?['results'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    return results
        .where((m) => m['poster_path'] != null)
        .take(12)
        .map((m) => _toResult(m, type))
        .toList();
  }

  static List<CastMember> _cast(Map credits) =>
      ((credits['cast'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .take(15)
          .map((c) => CastMember(
        name: (c['name'] as String?) ?? '',
        character: c['character'] as String?,
        photoUrl: _profile(c['profile_path'] as String?),
      ))
          .toList();

  /// Search movies or series by title.
  Future<List<SearchResult>> search(MediaType type, String query) async {
    final isMovie = type == MediaType.movie;
    final res = await _dio.get(
      isMovie ? '/search/movie' : '/search/tv',
      queryParameters: {'query': query, 'include_adult': false},
    );
    final results = (res.data['results'] as List).cast<Map<String, dynamic>>();
    return results.map((m) => _toResult(m, type)).toList();
  }

  Future<String> movieGenres(String id) async {
    final res = await _dio.get('/movie/$id');
    return _genreNames(res.data['genres']);
  }

  /// Rating, runtime, certification, director, cast and recommendations.
  Future<MovieInfo> movieInfo(String id) async {
    final res = await _dio.get(
      '/movie/$id',
      queryParameters: {
        'append_to_response': 'credits,release_dates,recommendations',
      },
    );
    final data = res.data as Map<String, dynamic>;
    final credits = (data['credits'] as Map?) ?? const {};

    final directors = ((credits['crew'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .where((c) => c['job'] == 'Director')
        .map((c) => (c['name'] as String?) ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final runtime = (data['runtime'] as num?)?.toInt();
    final tagline = (data['tagline'] as String?)?.trim();

    return MovieInfo(
      tagline: (tagline == null || tagline.isEmpty) ? null : tagline,
      runtime: (runtime == null || runtime == 0) ? null : runtime,
      voteAverage: (data['vote_average'] as num?)?.toDouble(),
      voteCount: (data['vote_count'] as num?)?.toInt() ?? 0,
      certification: _certification(data['release_dates']),
      directors: directors,
      cast: _cast(credits),
      similar: _similar(data['recommendations'], MediaType.movie),
    );
  }

  /// Rating, runtime, certification, creators, cast and recommendations.
  Future<SeriesInfo> seriesInfo(String id) async {
    final res = await _dio.get(
      '/tv/$id',
      queryParameters: {
        'append_to_response': 'credits,content_ratings,recommendations',
      },
    );
    final data = res.data as Map<String, dynamic>;
    final credits = (data['credits'] as Map?) ?? const {};

    final runs = (data['episode_run_time'] as List?) ?? const [];
    final runtime = runs.isNotEmpty
        ? (runs.first as num).toInt()
        : ((data['last_episode_to_air'] as Map?)?['runtime'] as num?)?.toInt();

    final creators = ((data['created_by'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map((c) => (c['name'] as String?) ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final tagline = (data['tagline'] as String?)?.trim();

    return SeriesInfo(
      tagline: (tagline == null || tagline.isEmpty) ? null : tagline,
      runtime: (runtime == null || runtime == 0) ? null : runtime,
      voteAverage: (data['vote_average'] as num?)?.toDouble(),
      voteCount: (data['vote_count'] as num?)?.toInt() ?? 0,
      certification: _tvRating(data['content_ratings']),
      status: data['status'] as String?,
      creators: creators,
      cast: _cast(credits),
      similar: _similar(data['recommendations'], MediaType.series),
    );
  }

  /// First age rating found for Australia, then the US.
  static String? _certification(dynamic releaseDates) {
    final results = ((releaseDates as Map?)?['results'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        const [];
    for (final country in ['AU', 'US']) {
      for (final r in results.where((r) => r['iso_3166_1'] == country)) {
        final dates = ((r['release_dates'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();
        for (final d in dates) {
          final c = (d['certification'] as String?)?.trim();
          if (c != null && c.isNotEmpty) return c;
        }
      }
    }
    return null;
  }

  static String? _tvRating(dynamic contentRatings) {
    final results = ((contentRatings as Map?)?['results'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    for (final country in ['AU', 'US']) {
      for (final r in results.where((r) => r['iso_3166_1'] == country)) {
        final c = (r['rating'] as String?)?.trim();
        if (c != null && c.isNotEmpty) return c;
      }
    }
    return null;
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