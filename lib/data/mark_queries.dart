import 'package:drift/drift.dart';

import 'app_database.dart';

extension MarkQueries on AppDatabase {
  Future<void> resetToWant(int itemId) => transaction(() async {
    await (delete(watchLogs)..where((l) => l.itemId.equals(itemId))).go();
    await (delete(readingLogs)..where((l) => l.itemId.equals(itemId))).go();
    await (update(mediaItems)..where((t) => t.id.equals(itemId)))
        .write(const MediaItemsCompanion(currentPage: Value(0)));
    await setStatus(itemId, Status.want, touch: false);
  });
}