import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../data/app_database.dart';
import '../api/tmdb_client.dart'; // <- adjust to where your tmdb_client.dart is
import 'episode_refresher.dart';
import 'notifications.dart';

/// Name used to identify the daily task inside Android's scheduler.
/// Registering the same name twice does not create a duplicate.
const String episodeCheckUniqueName = 'bookmark.episodeCheck';

/// Name passed to the callback so it knows which job is running.
const String episodeCheckTaskName = 'episodeCheck';

/// Where the time of the last successful check is saved (milliseconds).
const String lastCheckKey = 'lastEpisodeCheck';

/// This function is the entry point for ALL background work.
/// `@pragma('vm:entry-point')` stops Dart from removing it in release
/// builds, because nothing in the app calls it directly (Android does).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[Worker] started: $task');
    try {
      if (task == episodeCheckTaskName) {
        final prefs = SharedPreferencesAsync();
        final lastMillis = await prefs.getInt(lastCheckKey);
        final since = lastMillis == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastMillis);
        final startedAt = DateTime.now();

        // The worker has its own isolate, so it opens its own connection
        // to the same SQLite file.
        final db = AppDatabase();
        try {
          final report =
          await EpisodeRefresher(db, TmdbClient()).run(since: since);
          debugPrint('[Worker] done: $report');

          if (report.alerts.isNotEmpty) {
            await initNotifications(); // each isolate needs its own setup
            for (final a in report.alerts) {
              await showNewEpisodes(
                id: a.seriesId,
                title: a.title,
                body: a.body,
                imageUrl: a.imageUrl,
              );
            }
          }

          // Only move the "last checked" time forward when nothing failed,
          // so a network hiccup never makes you miss an episode.
          if (report.failed == 0) {
            await prefs.setInt(lastCheckKey, startedAt.millisecondsSinceEpoch);
          }

          // false = Android retries later (only when everything failed).
          return !report.shouldRetry;
        } finally {
          await db.close();
        }
      }
      return true;
    } catch (e, st) {
      debugPrint('[Worker] failed: $e\n$st');
      return false;
    }
  });
}

/// Call once at app start. Safe to call on every launch.
Future<void> initBackgroundWork() async {
  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    episodeCheckUniqueName,
    episodeCheckTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(hours: 1),
    constraints: Constraints(networkType: NetworkType.connected),
    // keep = if it is already scheduled, leave it alone
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

/// Temporary helper for testing: runs the task once, right now.
/// Remove it (and its call in main.dart) when testing is done.
Future<void> runEpisodeCheckNow() async {
  await Workmanager().registerOneOffTask(
    'bookmark.episodeCheck.debug',
    episodeCheckTaskName,
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}