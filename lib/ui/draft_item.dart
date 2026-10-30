import '../api/search_result.dart';
import '../data/app_database.dart';

/// A draft is an item shown from a search result. It is not saved yet.
/// It has a negative id, which no saved item ever has.
extension DraftItem on MediaItem {
  bool get isDraft => id < 0;
}

MediaItem draftFromResult(SearchResult r) {
  final now = DateTime.now();
  return MediaItem(
    id: -1,
    type: r.type,
    externalId: r.externalId,
    title: r.title,
    posterUrl: r.posterUrl,
    overview: r.overview,
    year: r.year,
    genres: r.genres,
    status: Status.want,
    rating: null,
    runtime: null,
    ongoing: null,
    author: r.author,
    pageCount: r.pageCount,
    currentPage: 0,
    dropReason: null,
    droppedAtPage: null,
    addedAt: now,
    lastActivityAt: now,
  );
}

SearchResult resultFromDraft(MediaItem item) => SearchResult(
  type: item.type,
  externalId: item.externalId,
  title: item.title,
  year: item.year,
  posterUrl: item.posterUrl,
  overview: item.overview,
  author: item.author,
  pageCount: item.pageCount,
  genres: item.genres,
);