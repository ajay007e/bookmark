import '../data/app_database.dart';

/// One search hit from TMDB (movie, series) or Open Library (book).
class SearchResult {
  const SearchResult({
    required this.type,
    required this.externalId,
    required this.title,
    this.year,
    this.posterUrl,
    this.overview,
    this.author,
    this.pageCount,
    this.genres = '',
  });

  final MediaType type;
  final String externalId;
  final String title;
  final int? year;
  final String? posterUrl;
  final String? overview;
  final String? author;
  final int? pageCount;
  final String genres;

  String get subtitle => [
    if (year != null) '$year',
    if (author != null) author!,
  ].join(' · ');
}

class EpisodeInfo {
  const EpisodeInfo({
    required this.season,
    required this.number,
    this.title,
    this.airDate,
  });

  final int season;
  final int number;
  final String? title;
  final DateTime? airDate;
}

class SeriesDetails {
  const SeriesDetails({required this.genres, required this.episodes});

  final String genres;
  final List<EpisodeInfo> episodes;
}