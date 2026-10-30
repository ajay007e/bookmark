import 'package:drift/drift.dart';

import 'app_database.dart';

extension MarkQueries on AppDatabase {
  /// Back to Want for a movie or book: removes every history row of the item,
  /// so it no longer counts in your stats.
  Future<void> resetToWant(int itemId) => transaction(() async {
    await (delete(watchLogs)..where((l) => l.itemId.equals(itemId))).go();
    await setStatus(itemId, Status.want, touch: false);
  });
}