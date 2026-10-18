import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/open_library_client.dart';
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