import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../api/tmdb_client.dart'; // <- adjust to where your tmdb_client.dart is

/// One series that has episodes to tell the user about.
class NewEpisodeAlert {
  NewEpisodeAlert(this.seriesId, this.title, this.imageUrl, this.episodes);

  final int seriesId;
  final String title;
  final String? imageUrl; // wide backdrop, or the poster as a fallback
  final List<Episode> episodes;

  String get body {
    if (episodes.length == 1) {
      final e = episodes.first;
      final name = (e.title == null || e.title!.isEmpty) ? '' : ' · ${e.title}';
      return 'S${e.seasonNumber} E${e.episodeNumber}$name is out';
    }
    return '${episodes.length} new episodes are out';
  }
}

/// The calendar day of [d] in local time (the clock time is dropped).
DateTime _dayOf(DateTime d) {
  final local = d.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// True when [e] should be announced:
/// - it has an air date (no date = never),
/// - that day has arrived (today counts), and
/// - it is later than the day of the previous check.
/// TMDB only gives a date, so days are compared, not times.
bool airedSinceLastCheck(Episode e, DateTime since, DateTime now) {
  final airDate = e.airDate;
  if (airDate == null) return false;
  final day = _dayOf(airDate);
  return day.isAfter(_dayOf(since)) && !day.isAfter(_dayOf(now));
}

/// What one refresh run did.
class RefreshReport {
  RefreshReport({
    this.checked = 0,
    this.newEpisodes = 0,
    this.failed = 0,
  });

  int checked; // series successfully refreshed
  int newEpisodes;
  int failed; // series that could not be refreshed (network, TMDB error)
  final List<NewEpisodeAlert> alerts = [];

  int get total => checked + failed;

  /// True only when every series failed, so Android retries later.
  bool get shouldRetry => total > 0 && failed == total;

  @override
  String toString() =>
      'checked $checked, new episodes $newEpisodes, failed $failed, '
          'alerts ${alerts.length}';
}

/// Refreshes details and episodes of every series in the library.
class EpisodeRefresher {
  EpisodeRefresher(this._db, this._tmdb);

  final AppDatabase _db;
  final TmdbClient _tmdb;

  /// [since] is the time of the previous successful check. Unticked
  /// episodes whose air date has arrived since then are reported in `alerts`.
  /// When [since] is null (first run) no alerts are made.
  Future<RefreshReport> run({DateTime? since}) async {
    final report = RefreshReport();
    final now = DateTime.now();
    final library = await _db.allSeries();

    for (final series in library) {
      // One bad series (or a network blip) must not stop the others.
      try {
        final details = await _tmdb.seriesDetails(series.externalId);

        final added = await _db.applySeriesRefresh(
          series.id,
          genres: details.genres,
          runtime: details.runtime,
          ongoing: details.ongoing,
          fresh: [
            for (final e in details.episodes)
              EpisodesCompanion.insert(
                seriesId: series.id,
                seasonNumber: e.season,
                episodeNumber: e.number,
                title: Value(e.title),
                airDate: Value(e.airDate),
                runtime: Value(e.runtime),
              ),
          ],
        );

        report.checked++;
        report.newEpisodes += added;
        if (added > 0) {
          debugPrint('[Worker] "${series.title}": $added new episode(s)');
        }

        // Only series you follow: Watching or Watched (not wishlist/dropped).
        final following = series.status == Status.inProgress ||
            series.status == Status.done;
        if (since != null && following) {
          final fresh = (await _db.episodesOf(series.id))
              .where((e) => !e.watched && airedSinceLastCheck(e, since, now))
              .toList()
            ..sort((a, b) {
              final s = a.seasonNumber.compareTo(b.seasonNumber);
              return s != 0 ? s : a.episodeNumber.compareTo(b.episodeNumber);
            });
          if (fresh.isNotEmpty) {
            // Wide image for the notification. Never fails the series:
            // if it can't be fetched, the saved poster is used instead.
            String? image;
            try {
              image = await _tmdb.seriesBackdrop(series.externalId);
            } catch (_) {}
            report.alerts.add(NewEpisodeAlert(
              series.id,
              series.title,
              image ?? series.posterUrl,
              fresh,
            ));
          }
        }
      } catch (e) {
        report.failed++;
        debugPrint('[Worker] "${series.title}" failed: $e');
      }
    }
    return report;
  }
}