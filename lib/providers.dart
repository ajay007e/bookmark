import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/detail_info.dart';
import 'api/open_library_client.dart';
import 'api/search_result.dart';
import 'api/tmdb_client.dart';
import 'data/app_database.dart';
import 'data/library_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final tmdbProvider = Provider<TmdbClient>((ref) => TmdbClient());

final openLibraryProvider =
Provider<OpenLibraryClient>((ref) => OpenLibraryClient());

final repositoryProvider = Provider<LibraryRepository>(
      (ref) => LibraryRepository(ref.watch(databaseProvider), ref.watch(tmdbProvider)),
);

final itemCountProvider = StreamProvider<int>(
      (ref) => ref.watch(databaseProvider).itemCount(),
);

final heroProvider = StreamProvider<List<MediaItem>>(
      (ref) => ref.watch(databaseProvider).hero(),
);

final recentWatchedProvider = StreamProvider<List<MediaItem>>(
      (ref) => ref.watch(databaseProvider).recentWatched(),
);

final recentReadProvider = StreamProvider<List<MediaItem>>(
      (ref) => ref.watch(databaseProvider).recentRead(),
);

final wishlistProvider = StreamProvider.family<List<MediaItem>, MediaType>(
      (ref, type) => ref.watch(databaseProvider).wishlist(type),
);

final itemsByTypeProvider = StreamProvider.family<List<MediaItem>, MediaType>(
      (ref, type) => ref.watch(databaseProvider).byType(type),
);

/// One item by its database id. Updates live when the item changes.
final itemProvider = StreamProvider.family<MediaItem?, int>(
      (ref, id) => ref.watch(databaseProvider).watchItem(id),
);

/// Extra movie details (rating, cast, runtime) from TMDB, fetched when a page opens.
final movieInfoProvider = FutureProvider.family<MovieInfo, String>(
      (ref, tmdbId) => ref.watch(tmdbProvider).movieInfo(tmdbId),
  retry: (count, error) => null, // no automatic retries, so the offline note shows quickly
);

/// Extra book details (description, rating, subjects) from Open Library.
final bookInfoProvider = FutureProvider.family<BookInfo, String>(
      (ref, workKey) => ref.watch(openLibraryProvider).bookInfo(workKey),
  retry: (count, error) => null,
);

/// Extra series details (rating, cast, recommendations) from TMDB.
final seriesInfoProvider = FutureProvider.family<SeriesInfo, String>(
      (ref, tmdbId) => ref.watch(tmdbProvider).seriesInfo(tmdbId),
  retry: (count, error) => null,
);

/// All episodes of one series (by database id). Updates live when ticked.
final episodesProvider = StreamProvider.family<List<Episode>, int>(
      (ref, seriesId) => ref.watch(databaseProvider).watchEpisodes(seriesId),
);

typedef BookKey = ({String key, String title, String? author});

/// "You may also like" for a book. Waits for the book's subjects first.
final bookSimilarProvider = FutureProvider.family<List<SearchResult>, BookKey>(
      (ref, book) async {
    final info = await ref.watch(bookInfoProvider(book.key).future);
    return ref.watch(openLibraryProvider).similarBooks(
      workKey: book.key,
      title: book.title,
      author: book.author,
      subjects: info.subjects,
    );
  },
  retry: (count, error) => null,
);