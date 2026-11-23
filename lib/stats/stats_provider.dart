import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stats_queries.dart';
import '../providers.dart';
import 'stats_models.dart';

export 'stats_models.dart';

final statsProvider = StreamProvider.family<WatchStats, StatsPeriod>(
      (ref, period) => ref.watch(databaseProvider).watchStats(period.since),
);

final statEntriesProvider = StreamProvider.family<List<StatEntry>, StatsPeriod>(
      (ref, period) => ref.watch(databaseProvider).watchStatEntries(period.since),
);

final readEntriesProvider = StreamProvider.family<List<ReadEntry>, StatsPeriod>(
      (ref, period) => ref.watch(databaseProvider).watchReadEntries(period.since),
);

final readDaysProvider = StreamProvider<Set<DateTime>>(
      (ref) => ref.watch(databaseProvider).watchReadDays(),
);

final detailStatsProvider = Provider.family<AsyncValue<StatsSummary>, StatsKey>(
      (ref, key) {
    final entries = ref.watch(statEntriesProvider(key.period));

    if (key.filter != StatsFilter.books) {
      return entries.whenData(
            (e) => buildSummary(e, key.filter, key.period, DateTime.now()),
      );
    }

    final reads = ref.watch(readEntriesProvider(key.period));
    final days = ref.watch(readDaysProvider);

    final e = entries.asData?.value;
    final r = reads.asData?.value;
    final d = days.asData?.value;
    if (e != null && r != null && d != null) {
      return AsyncData(buildSummary(
        e,
        key.filter,
        key.period,
        DateTime.now(),
        reads: r,
        readDays: d,
      ));
    }
    final error = entries.error ?? reads.error ?? days.error;
    if (error != null) return AsyncError(error, StackTrace.current);
    return const AsyncLoading();
  },
);