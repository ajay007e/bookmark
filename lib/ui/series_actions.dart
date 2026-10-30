import 'dart:math' show max, min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'draft_item.dart';

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

/// true = watched now, false = watched earlier, null = cancelled.
Future<bool?> askNowOrEarlier(BuildContext context, {required String title}) {
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Watched now'),
            subtitle: const Text('Counts in your watch time'),
            onTap: () => Navigator.of(sheetContext).pop(true),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Watched earlier'),
            subtitle: const Text('Not counted in your watch time'),
            onTap: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      ),
    ),
  );
}

/// Marks [targets] as watched. [counted] true = watched now, false = earlier.
/// If earlier aired episodes (this season or earlier seasons) are still
/// unticked, asks whether to tick them too. Those earlier ones are always
/// saved as "watched earlier", so they stay out of your watch time.
Future<void> tickEpisodes(
    BuildContext context,
    WidgetRef ref, {
      required int seriesId,
      required List<Episode> all,
      required List<Episode> targets,
      bool counted = true,
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
  await db.setEpisodesWatched(seriesId, targetIds, true, counted: counted);
}

/// Like [tickEpisodes], but also works for a series that is not saved yet:
/// it saves the series (as Want, with all its episodes) and then marks the
/// same episodes in the saved copy.
Future<void> markEpisodes(
    BuildContext context,
    WidgetRef ref, {
      required MediaItem series,
      required List<Episode> all,
      required List<Episode> targets,
      bool counted = true,
    }) async {
  if (!series.isDraft) {
    return tickEpisodes(
      context,
      ref,
      seriesId: series.id,
      all: all,
      targets: targets,
      counted: counted,
    );
  }

  final db = ref.read(databaseProvider);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(repositoryProvider).add(resultFromDraft(series), Status.want);
  } catch (_) {
    messenger.showSnackBar(const SnackBar(
      content: Text('Could not add it. Check your connection and try again.'),
    ));
    return;
  }

  final id = await db.findId(series.type, series.externalId);
  if (id == null || !context.mounted) return;

  // Match the unsaved episodes with the saved ones by season and number.
  final saved = await db.episodesOf(id);
  final wanted = {for (final e in targets) (e.seasonNumber, e.episodeNumber)};
  final savedTargets = [
    for (final e in saved)
      if (wanted.contains((e.seasonNumber, e.episodeNumber))) e,
  ];

  await tickEpisodes(
    context,
    ref,
    seriesId: id,
    all: saved,
    targets: savedTargets,
    counted: counted,
  );
}

/// The episode to watch next: the first aired, unticked episode after the
/// furthest one you have ticked. If there is none after it, the earliest
/// aired, unticked episode. null when you are all caught up.
Episode? nextEpisode(List<Episode> eps, DateTime now) {
  final todo = eps.where((e) => !e.watched && isAired(e, now)).toList()
    ..sort((a, b) => _order(a).compareTo(_order(b)));
  if (todo.isEmpty) return null;
  final furthest = eps.where((e) => e.watched).map(_order).fold<int>(-1, max);
  return todo.firstWhere((e) => _order(e) > furthest, orElse: () => todo.first);
}