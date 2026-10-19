import 'search_result.dart';

/// TMDB show status -> is it still running? null when unknown.
bool? showIsOngoing(String? status) => switch (status) {
  'Returning Series' || 'In Production' || 'Planned' || 'Pilot' => true,
  'Ended' || 'Canceled' => false,
  _ => null,
};

class CastMember {
  const CastMember({required this.name, this.character, this.photoUrl});

  final String name;
  final String? character;
  final String? photoUrl;
}

/// A streaming service, rental shop and so on.
class WatchProvider {
  const WatchProvider({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;
}

/// Where something can be watched (from TMDB, data by JustWatch).
class WatchOptions {
  const WatchOptions({
    this.link,
    this.stream = const [],
    this.free = const [],
    this.rent = const [],
    this.buy = const [],
  });

  final String? link; // TMDB's watch page, which links to each service
  final List<WatchProvider> stream;
  final List<WatchProvider> free;
  final List<WatchProvider> rent;
  final List<WatchProvider> buy;

  bool get isEmpty =>
      stream.isEmpty && free.isEmpty && rent.isEmpty && buy.isEmpty;
}

/// Extra movie details that are fetched when the detail page opens.
class MovieInfo {
  const MovieInfo({
    this.tagline,
    this.runtime,
    this.voteAverage,
    this.voteCount = 0,
    this.certification,
    this.directors = const [],
    this.writers = const [],
    this.cast = const [],
    this.similar = const [],
    this.releaseDate,
    this.releaseCountry,
    this.language,
    this.status,
    this.watch,
  });

  final String? tagline;
  final int? runtime; // minutes
  final double? voteAverage; // out of 10
  final int voteCount;
  final String? certification; // for example PG-13 or M
  final List<String> directors;
  final List<String> writers;
  final List<CastMember> cast;
  final List<SearchResult> similar;
  final DateTime? releaseDate;
  final String? releaseCountry; // null when the date is the general one
  final String? language; // original language, for example "English"
  final String? status; // Released, Post Production, ...
  final WatchOptions? watch;
}

/// Extra series details from TMDB.
/// One season, as listed on the series page.
class SeasonInfo {
  const SeasonInfo({
    required this.number,
    this.overview,
    this.posterUrl,
    this.voteAverage,
    this.airDate,
    this.episodeCount = 0,
  });

  final int number;
  final String? overview;
  final String? posterUrl;
  final double? voteAverage; // out of 10
  final DateTime? airDate;
  final int episodeCount;
}

/// Extra details of one episode (fetched when the season page opens).
class EpisodeDetail {
  const EpisodeDetail({
    this.title,
    this.overview,
    this.stillUrl,
    this.voteAverage,
    this.runtime,
    this.airDate,
  });

  final String? title;
  final String? overview;
  final String? stillUrl;
  final double? voteAverage; // out of 10
  final int? runtime; // minutes
  final DateTime? airDate;
}

class SeasonDetail {
  const SeasonDetail({this.posterUrl, this.airDate, this.episodes = const {}});

  final String? posterUrl;
  final DateTime? airDate;
  final Map<int, EpisodeDetail> episodes; // by episode number
}

/// Extra series details from TMDB.
class SeriesInfo {
  const SeriesInfo({
    this.tagline,
    this.runtime,
    this.voteAverage,
    this.voteCount = 0,
    this.certification,
    this.status,
    this.language,
    this.creators = const [],
    this.cast = const [],
    this.similar = const [],
    this.watch,
    this.seasons = const [],
  });

  final String? tagline;
  final int? runtime; // minutes per episode
  final double? voteAverage; // out of 10
  final int voteCount;
  final String? certification;
  final String? status; // for example "Returning Series" or "Ended"
  final String? language; // original language, for example "English"
  final List<String> creators;
  final List<CastMember> cast;
  final List<SearchResult> similar;
  final WatchOptions? watch;
  final List<SeasonInfo> seasons;

  bool? get ongoing => showIsOngoing(status);
}

/// Extra book details from Open Library.
class BookInfo {
  const BookInfo({
    this.description,
    this.ratingAverage,
    this.ratingCount = 0,
    this.subjects = const [],
    this.language,
    this.publisher,
    this.pages,
  });

  final String? description;
  final double? ratingAverage; // out of 5
  final int ratingCount;
  final List<String> subjects;
  final String? language;
  final String? publisher;
  final int? pages; // from the chosen edition
}