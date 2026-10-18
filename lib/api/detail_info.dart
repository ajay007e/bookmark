import 'search_result.dart';

class CastMember {
  const CastMember({required this.name, this.character, this.photoUrl});

  final String name;
  final String? character;
  final String? photoUrl;
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
    this.cast = const [],
    this.similar = const [],
  });

  final String? tagline;
  final int? runtime; // minutes
  final double? voteAverage; // out of 10
  final int voteCount;
  final String? certification; // for example PG-13 or M
  final List<String> directors;
  final List<CastMember> cast;
  final List<SearchResult> similar;
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
    this.creators = const [],
    this.cast = const [],
    this.similar = const [],
  });

  final String? tagline;
  final int? runtime; // minutes per episode
  final double? voteAverage; // out of 10
  final int voteCount;
  final String? certification;
  final String? status; // for example "Returning Series" or "Ended"
  final List<String> creators;
  final List<CastMember> cast;
  final List<SearchResult> similar;
}

/// Extra book details from Open Library.
class BookInfo {
  const BookInfo({
    this.description,
    this.ratingAverage,
    this.ratingCount = 0,
    this.subjects = const [],
  });

  final String? description;
  final double? ratingAverage; // out of 5
  final int ratingCount;
  final List<String> subjects;
}