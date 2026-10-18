import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

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