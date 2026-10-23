import 'package:dio/dio.dart';

import '../config/secrets.dart';
import '../data/app_database.dart';
import 'detail_info.dart';
import 'search_result.dart';

/// Streaming availability is shown for this country.
const watchRegion = 'AU';

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

  static int? _minutes(dynamic v) {
    final n = (v as num?)?.toInt();
    return (n == null || n == 0) ? null : n;
  }

  static int? _seriesRuntime(Map<String, dynamic> data) {
    final runs = (data['episode_run_time'] as List?) ?? const [];
    final value = runs.isNotEmpty
        ? runs.first
        : (data['last_episode_to_air'] as Map?)?['runtime'];
    return _minutes(value);
  }

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

  /// Genres and runtime, saved when a movie is added.
  Future<({String genres, int? runtime})> movieBasics(String id) async {
    final res = await _dio.get('/movie/$id');
    return (
    genres: _genreNames(res.data['genres']),
    runtime: _minutes(res.data['runtime']),
    );
  }

  /// Everything the movie page shows beyond what is saved on the phone.
  Future<MovieInfo> movieInfo(String id) async {
    final res = await _dio.get(
      '/movie/$id',
      queryParameters: {
        'append_to_response': 'credits,release_dates,recommendations,watch/providers',
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

    final tagline = (data['tagline'] as String?)?.trim();
    final release = _release(data);

    return MovieInfo(
      tagline: (tagline == null || tagline.isEmpty) ? null : tagline,
      runtime: _minutes(data['runtime']),
      voteAverage: (data['vote_average'] as num?)?.toDouble(),
      voteCount: (data['vote_count'] as num?)?.toInt() ?? 0,
      certification: _certification(data['release_dates']),
      directors: directors,
      writers: _writers(credits),
      cast: _cast(credits),
      similar: _similar(data['recommendations'], MediaType.movie),
      releaseDate: release.date,
      releaseCountry: release.country,
      language: _language(data),
      status: data['status'] as String?,
      watch: _watchOptions(data['watch/providers']),
    );
  }

  /// Rating, runtime, certification, creators, cast and recommendations.
  /// Everything the series page shows beyond what is saved on the phone.
  Future<SeriesInfo> seriesInfo(String id) async {
    final res = await _dio.get(
      '/tv/$id',
      queryParameters: {
        'append_to_response':
        'credits,content_ratings,recommendations,watch/providers',
      },
    );
    final data = res.data as Map<String, dynamic>;
    final credits = (data['credits'] as Map?) ?? const {};

    final creators = ((data['created_by'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map((c) => (c['name'] as String?) ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final tagline = (data['tagline'] as String?)?.trim();

    final seasons = ((data['seasons'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .where((s) => ((s['season_number'] as num?)?.toInt() ?? 0) > 0)
        .map((s) {
      final air = s['air_date'] as String?;
      final vote = (s['vote_average'] as num?)?.toDouble();
      final overview = (s['overview'] as String?)?.trim();
      return SeasonInfo(
        number: (s['season_number'] as num).toInt(),
        overview: (overview == null || overview.isEmpty) ? null : overview,
        posterUrl: _seasonPoster(s['poster_path'] as String?),
        voteAverage: (vote == null || vote == 0) ? null : vote,
        airDate: (air == null || air.isEmpty) ? null : DateTime.tryParse(air),
        episodeCount: (s['episode_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return SeriesInfo(
      tagline: (tagline == null || tagline.isEmpty) ? null : tagline,
      runtime: _seriesRuntime(data),
      voteAverage: (data['vote_average'] as num?)?.toDouble(),
      voteCount: (data['vote_count'] as num?)?.toInt() ?? 0,
      certification: _tvRating(data['content_ratings']),
      status: data['status'] as String?,
      language: _language(data),
      creators: creators,
      cast: _cast(credits),
      similar: _similar(data['recommendations'], MediaType.series),
      watch: _watchOptions(data['watch/providers']),
      seasons: seasons,
    );
  }

  /// Poster, and every episode's image, rating, runtime and description.
  Future<SeasonDetail> seasonDetail(String tvId, int season) async {
    final res = await _dio.get('/tv/$tvId/season/$season');
    final data = res.data as Map<String, dynamic>;

    final episodes = <int, EpisodeDetail>{};
    for (final e in ((data['episodes'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()) {
      final number = (e['episode_number'] as num).toInt();
      final air = e['air_date'] as String?;
      final vote = (e['vote_average'] as num?)?.toDouble();
      final overview = (e['overview'] as String?)?.trim();
      episodes[number] = EpisodeDetail(
        title: e['name'] as String?,
        overview: (overview == null || overview.isEmpty) ? null : overview,
        stillUrl: _still(e['still_path'] as String?),
        voteAverage: (vote == null || vote == 0) ? null : vote,
        runtime: _minutes(e['runtime']),
        airDate: (air == null || air.isEmpty) ? null : DateTime.tryParse(air),
      );
    }

    final air = data['air_date'] as String?;
    return SeasonDetail(
      posterUrl: _seasonPoster(data['poster_path'] as String?),
      airDate: (air == null || air.isEmpty) ? null : DateTime.tryParse(air),
      episodes: episodes,
    );
  }

  static String? _logo(String? path) =>
      path == null ? null : 'https://image.tmdb.org/t/p/w92$path';

  static String? _still(String? path) =>
      path == null ? null : 'https://image.tmdb.org/t/p/w300$path';

  static String? _seasonPoster(String? path) =>
      path == null ? null : 'https://image.tmdb.org/t/p/w342$path';

  /// Streaming, free, rental and purchase options in [watchRegion].
  static WatchOptions _watchOptions(dynamic block) {
    final region = ((block as Map?)?['results'] as Map?)?[watchRegion] as Map?;
    if (region == null) return const WatchOptions();

    List<WatchProvider> list(String key) => ((region[key] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map((p) => WatchProvider(
      name: (p['provider_name'] as String?) ?? '',
      logoUrl: _logo(p['logo_path'] as String?),
    ))
        .toList();

    return WatchOptions(
      link: region['link'] as String?,
      stream: list('flatrate'),
      free: [...list('free'), ...list('ads')],
      rent: list('rent'),
      buy: list('buy'),
    );
  }

  /// Writers, screenplay and story credits (first three names).
  static List<String> _writers(Map credits) {
    const jobs = {'Screenplay', 'Writer', 'Story'};
    final names = <String>[];
    for (final c in ((credits['crew'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()) {
      if (!jobs.contains(c['job'])) continue;
      final name = (c['name'] as String?) ?? '';
      if (name.isNotEmpty && !names.contains(name)) names.add(name);
    }
    return names.take(3).toList();
  }

  /// "en" -> "English", using the movie's own list of spoken languages.
  static String? _language(Map<String, dynamic> data) {
    final code = data['original_language'] as String?;
    if (code == null || code.isEmpty) return null;
    final spoken = ((data['spoken_languages'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    for (final l in spoken) {
      if (l['iso_639_1'] == code) {
        final name = l['english_name'] as String?;
        if (name != null && name.isNotEmpty) return name;
      }
    }
    return code.toUpperCase();
  }

  /// Earliest cinema release in Australia, then the US. Falls back to
  /// TMDB's general release date (without a country).
  static ({DateTime? date, String? country}) _release(Map<String, dynamic> data) {
    DateTime? day(String? s) =>
        (s == null || s.length < 10) ? null : DateTime.tryParse(s.substring(0, 10));

    final results = ((data['release_dates'] as Map?)?['results'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];

    for (final country in [watchRegion, 'US']) {
      DateTime? best;
      for (final r in results.where((r) => r['iso_3166_1'] == country)) {
        final dates = ((r['release_dates'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();
        for (final d in dates) {
          final type = d['type']; // 2 and 3 are cinema releases
          if (type != 2 && type != 3) continue;
          final date = day(d['release_date'] as String?);
          if (date != null && (best == null || date.isBefore(best))) best = date;
        }
      }
      if (best != null) return (date: best, country: country);
    }
    return (date: day(data['release_date'] as String?), country: null);
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

  /// Genres, runtime, show status and every episode of every season
  /// (specials are skipped).
  Future<SeriesDetails> seriesDetails(String id) async {
    final res = await _dio.get('/tv/$id');
    final data = res.data as Map<String, dynamic>;
    final genres = _genreNames(data['genres']);

    final seasonNumbers = (data['seasons'] as List)
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
          runtime: _minutes(e['runtime']),
        ));
      }
    }
    return SeriesDetails(
      genres: genres,
      episodes: episodes,
      runtime: _seriesRuntime(data),
      ongoing: showIsOngoing(data['status'] as String?),
    );
  }

  /// Wide backdrop image of a series (used in notifications). Null if none.
  Future<String?> seriesBackdrop(String id) async {
    final res = await _dio.get('/tv/$id');
    final path = res.data['backdrop_path'] as String?;
    return path == null ? null : 'https://image.tmdb.org/t/p/w780$path';
  }
}