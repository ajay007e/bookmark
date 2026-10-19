import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'series_actions.dart';
import 'widgets/drop_sheet.dart';

enum WatchAction {
  wishlist,
  reading,
  watchedNow,
  watchedEarlier,
  unwatched,
  didNotComplete,
  remove,
}

/// Unknown counts as ongoing until TMDB tells us otherwise.
bool _isOngoing(MediaItem item) => item.ongoing ?? true;

/// The long-press menu for this item.
List<WatchAction> menuFor(MediaItem item, List<Episode> episodes) {
  final status = item.status;
  final done = status == Status.done;
  switch (item.type) {
    case MediaType.movie:
      return [
        if (status != Status.want) WatchAction.wishlist,
        WatchAction.watchedNow,
        if (!done) WatchAction.watchedEarlier,
        if (done) WatchAction.unwatched,
        WatchAction.remove,
      ];
    case MediaType.series:
      final started = episodes.any((e) => e.watched);
      return [
        if (!started && status != Status.want) WatchAction.wishlist,
        WatchAction.watchedNow,
        WatchAction.watchedEarlier,
        if (started) WatchAction.unwatched,
        WatchAction.remove,
      ];
    case MediaType.book:
      return [
        if (status != Status.want) WatchAction.wishlist,
        if (status != Status.inProgress) WatchAction.reading,
        WatchAction.watchedNow,
        if (!done) WatchAction.watchedEarlier,
        if (status != Status.dropped) WatchAction.didNotComplete,
        if (done) WatchAction.unwatched,
        WatchAction.remove,
      ];
  }
}

String actionLabel(MediaItem item, WatchAction a) {
  final book = item.type == MediaType.book;
  final series = item.type == MediaType.series;
  final done = item.status == Status.done;
  switch (a) {
    case WatchAction.wishlist:
      return book ? 'Want to read' : 'Add to wishlist';
    case WatchAction.reading:
      return 'Reading';
    case WatchAction.watchedNow:
      if (book) return done ? 'Read again now' : 'Read now';
      if (series) {
        return _isOngoing(item) ? 'Aired episodes watched now' : 'Watched now';
      }
      return done ? 'Watched again now' : 'Watched now';
    case WatchAction.watchedEarlier:
      if (book) return 'Read earlier';
      if (series && _isOngoing(item)) return 'Aired episodes watched earlier';
      return 'Watched earlier';
    case WatchAction.unwatched:
      return book ? 'Mark as unread' : 'Mark as unwatched';
    case WatchAction.didNotComplete:
      return 'Did not complete';
    case WatchAction.remove:
      return 'Remove from Bookmark';
  }
}

String? actionHint(WatchAction a) => switch (a) {
  WatchAction.watchedNow => 'Counts in your watch time',
  WatchAction.watchedEarlier => 'Not counted in your watch time',
  _ => null,
};

IconData actionIcon(WatchAction a) => switch (a) {
  WatchAction.wishlist => Icons.bookmark_add_outlined,
  WatchAction.reading => Icons.auto_stories_outlined,
  WatchAction.watchedNow => Icons.check_circle_outline,
  WatchAction.watchedEarlier => Icons.history,
  WatchAction.unwatched => Icons.undo,
  WatchAction.didNotComplete => Icons.block,
  WatchAction.remove => Icons.delete_outline,
};

/// Runs one option from the long-press menu.
Future<void> runWatchAction(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    WatchAction action, {
      List<Episode> episodes = const [],
    }) async {
  final db = ref.read(databaseProvider);
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final book = item.type == MediaType.book;
  final series = item.type == MediaType.series;
  final now = DateTime.now();
  final todo = episodes.where((e) => !e.watched && isAired(e, now)).toList();
  final started = episodes.any((e) => e.watched);

  switch (action) {
    case WatchAction.wishlist:
      await db.setStatus(item.id, Status.want);
    case WatchAction.reading:
      await db.setStatus(item.id, Status.inProgress);
    case WatchAction.watchedNow:
    case WatchAction.watchedEarlier:
      final counted = action == WatchAction.watchedNow;
      if (series) {
        if (todo.isEmpty) {
          messenger.showSnackBar(SnackBar(
            content: Text(started ? "You're up to date." : 'Nothing has aired yet.'),
          ));
          return;
        }
        await db.setEpisodesWatched(
          item.id,
          todo.map((e) => e.id),
          true,
          counted: counted,
        );
      } else {
        await db.markDone(item, counted: counted);
      }
    case WatchAction.unwatched:
      final okUnmark = await confirmDialog(
        context,
        title: book ? 'Mark as unread?' : 'Mark as unwatched?',
        message: series
            ? 'All episodes will be unticked and removed from your watch history.'
            : 'Your latest ${book ? 'read' : 'watch'} will be removed from your history.',
        yes: 'Unmark',
      );
      if (!okUnmark) return;
      if (series) {
        await db.clearSeriesProgress(item.id);
      } else {
        await db.markUnwatched(item.id);
      }
    case WatchAction.didNotComplete:
      final result = await showDropSheet(
        context,
        reason: item.dropReason,
        page: item.droppedAtPage,
        pageCount: item.pageCount,
      );
      if (result != null) await db.setDropped(item.id, result.reason, result.page);
    case WatchAction.remove:
      final okRemove = await confirmDialog(
        context,
        title: 'Remove from Bookmark?',
        message: '"${item.title}" and its history will be deleted.',
        yes: 'Remove',
      );
      if (!okRemove) return;
      router.pop();
      await db.deleteItem(item.id);
  }
}

/// A single tap on the tick button.
Future<void> tapTick(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    List<Episode> episodes,
    ) async {
  final db = ref.read(databaseProvider);
  final messenger = ScaffoldMessenger.of(context);
  final done = item.status == Status.done;

  // Movies and books: one tap = done now. Tap again = undo (asks first).
  if (item.type != MediaType.series) {
    if (done) {
      await runWatchAction(context, ref, item, WatchAction.unwatched);
    } else {
      await db.markDone(item, counted: true);
    }
    return;
  }

  // Series
  if (done) {
    await runWatchAction(context, ref, item, WatchAction.unwatched,
        episodes: episodes);
    return;
  }

  final now = DateTime.now();
  final todo = episodes.where((e) => !e.watched && isAired(e, now)).toList();
  if (todo.isEmpty) {
    messenger.showSnackBar(SnackBar(
      content: Text(episodes.any((e) => e.watched)
          ? "You're up to date."
          : 'Nothing has aired yet.'),
    ));
    return;
  }

  if (_isOngoing(item)) {
    // Still running: it stays "Watching", so ask when you watched them.
    final counted = await _askNowOrEarlier(context, todo.length);
    if (counted == null) return;
    await db.setEpisodesWatched(
      item.id,
      todo.map((e) => e.id),
      true,
      counted: counted,
    );
  } else {
    final ok = await confirmDialog(
      context,
      title: 'Mark as Watched?',
      message:
      '${todo.length} aired episode${todo.length == 1 ? '' : 's'} will be marked as watched now.',
      yes: 'Mark all',
    );
    if (ok) await db.setEpisodesWatched(item.id, todo.map((e) => e.id), true);
  }
}

/// true = watched now, false = watched earlier, null = cancelled.
Future<bool?> _askNowOrEarlier(BuildContext context, int count) {
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
            child: Text(
              'Mark $count aired episode${count == 1 ? '' : 's'} as watched',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
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