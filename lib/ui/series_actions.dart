import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';

/// An episode counts as aired when it has a date that is not in the future.
bool isAired(Episode e, DateTime now) =>
    e.airDate != null && !e.airDate!.isAfter(now);

// Orders episodes across seasons: season 2 episode 3 -> 20003.
int _order(Episode e) => e.seasonNumber * 10000 + e.episodeNumber;

Future<bool> confirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      String yes = 'Yes',
    }) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(yes),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Marks [targets] as watched now. If earlier aired episodes (this season or
/// earlier seasons) are still unticked, asks whether to tick them too.
/// Those earlier ones are saved as "watched earlier", so they stay out of
/// your watch time.
Future<void> tickEpisodes(
    BuildContext context,
    WidgetRef ref, {
      required int seriesId,
      required List<Episode> all,
      required List<Episode> targets,
    }) async {
  if (targets.isEmpty) return;
  final db = ref.read(databaseProvider);
  final now = DateTime.now();

  final targetIds = targets.map((e) => e.id).toSet();
  final first = targets.map(_order).reduce(min);
  final earlier = all
      .where((e) =>
  !e.watched &&
      isAired(e, now) &&
      !targetIds.contains(e.id) &&
      _order(e) < first)
      .toList();

  var earlierIds = <int>[];
  if (earlier.isNotEmpty) {
    final n = earlier.length;
    final answer = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark earlier episodes too?'),
        content: Text(
          '$n earlier episode${n == 1 ? ' is' : 's are'} not marked as watched yet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(targets.length == 1 ? 'Just this one' : 'Just these'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mark earlier too'),
          ),
        ],
      ),
    );
    if (answer == null) return; // Cancel or tapped outside: change nothing
    if (answer) earlierIds = earlier.map((e) => e.id).toList();
  }

  if (earlierIds.isNotEmpty) {
    await db.setEpisodesWatched(seriesId, earlierIds, true, counted: false);
  }
  await db.setEpisodesWatched(seriesId, targetIds, true);
}