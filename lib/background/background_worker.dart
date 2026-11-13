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

/// Where the You > New episodes switch is saved (true = on).
const String dailyCheckKey = 'dailyCheckEnabled';

/// Whether the daily check is switched on. On by default.
Future<bool> isDailyCheckEnabled() async =>
    await SharedPreferencesAsync().getBool(dailyCheckKey) ?? true;

/// This function is the entry point for ALL background work.
/// `@pragma('vm:entry-point')` stops Dart from removing it in release
/// builds, because nothing in the app calls it directly (Android does).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[Worker] started: $task');
    try {
      if (task == episodeCheckTaskName) {
        // Safety net: if the switch is off, do nothing.
        if (!await isDailyCheckEnabled()) {
          debugPrint('[Worker] daily check is off, skipping');
          return true;
        }

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

/// Schedules the daily task (about every 24 hours, on a network connection).
Future<void> _registerDailyCheck() {
  return Workmanager().registerPeriodicTask(
    episodeCheckUniqueName,
    episodeCheckTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(hours: 1),
    constraints: Constraints(networkType: NetworkType.connected),
    // keep = if it is already scheduled, leave it alone
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

/// Call once at app start. Safe to call on every launch.
/// Follows the saved switch: on = scheduled, off = cancelled.
Future<void> initBackgroundWork() async {
  await Workmanager().initialize(callbackDispatcher);

  if (await isDailyCheckEnabled()) {
    await _registerDailyCheck();
  } else {
    await Workmanager().cancelByUniqueName(episodeCheckUniqueName);
  }
}

/// Called by the You > New episodes switch. Saves the choice, then
/// schedules or cancels the daily task.
Future<void> setDailyCheck(bool enabled) async {
  await SharedPreferencesAsync().setBool(dailyCheckKey, enabled);
  if (enabled) {
    await _registerDailyCheck();
  } else {
    await Workmanager().cancelByUniqueName(episodeCheckUniqueName);
  }
  debugPrint('[Worker] daily check ${enabled ? 'ON' : 'OFF'}');
}