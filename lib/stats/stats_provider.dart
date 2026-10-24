import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stats_queries.dart';
import '../providers.dart';
import 'stats_models.dart';

// Screens that import this file also get StatsPeriod, StatsFilter and so on.
export 'stats_models.dart';

/// Small totals for the card on the You tab.
final statsProvider = StreamProvider.family<WatchStats, StatsPeriod>(
      (ref, period) => ref.watch(databaseProvider).watchStats(period.since),
);

/// Every counted history row for a period. Updates live when you tick something.
final statEntriesProvider = StreamProvider.family<List<StatEntry>, StatsPeriod>(
      (ref, period) => ref.watch(databaseProvider).watchStatEntries(period.since),
);

/// The numbers for one view (All, Movies, Series or Books) and one period.
final detailStatsProvider = Provider.family<AsyncValue<StatsSummary>, StatsKey>(
      (ref, key) => ref.watch(statEntriesProvider(key.period)).whenData(
        (entries) => buildSummary(entries, key.filter, key.period, DateTime.now()),
  ),
);