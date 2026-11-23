import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_database.dart';
import '../data/labels.dart';
import '../data/mark_queries.dart';
import '../data/reading_queries.dart';
import '../providers.dart';
import 'draft_item.dart';
import 'draft_saving.dart';
import 'reading_actions.dart';
import 'series_actions.dart';
import 'widgets/add_to_list_sheet.dart';
import 'widgets/drop_sheet.dart';
import 'widgets/progress_sheet.dart';

enum WatchAction {
  addToWant,
  watching,
  watchedNow,
  watchedEarlier,
  backToWant,
  unwatched,
  updateProgress,
  didNotComplete,
  addToList,
  remove,
}

class MenuEntry {
  const MenuEntry(this.action, {this.enabled = true, this.note});

  final WatchAction action;
  final bool enabled;
  final String? note;
}

List<MenuEntry> menuFor(MediaItem item, List<Episode> episodes) {
  switch (item.type) {
    case MediaType.movie:
      if (item.isDraft) {
        return const [
          MenuEntry(WatchAction.addToWant),
          MenuEntry(WatchAction.watchedEarlier),
          MenuEntry(WatchAction.addToList),
        ];
      }
      if (item.status == Status.done) {
        return const [
          MenuEntry(WatchAction.watchedNow),
          MenuEntry(WatchAction.addToList),
          MenuEntry(WatchAction.remove),
        ];
      }
      return const [
        MenuEntry(WatchAction.watching,
            enabled: false, note: 'Movies have no Watching status'),
        MenuEntry(WatchAction.watchedNow),
        MenuEntry(WatchAction.watchedEarlier),
        MenuEntry(WatchAction.addToList),
        MenuEntry(WatchAction.remove),
      ];

    case MediaType.book:
      if (item.isDraft) {
        return const [
          MenuEntry(WatchAction.addToWant),
          MenuEntry(WatchAction.watching),
          MenuEntry(WatchAction.watchedNow),
          MenuEntry(WatchAction.watchedEarlier),
          MenuEntry(WatchAction.addToList),
        ];
      }
      switch (item.status) {
        case Status.want:
          return const [
            MenuEntry(WatchAction.watching),
            MenuEntry(WatchAction.watchedNow),
            MenuEntry(WatchAction.watchedEarlier),
            MenuEntry(WatchAction.addToList),
            MenuEntry(WatchAction.remove),
          ];
        case Status.inProgress:
          return const [
            MenuEntry(WatchAction.watchedNow),
            MenuEntry(WatchAction.updateProgress),
            MenuEntry(WatchAction.didNotComplete),
            MenuEntry(WatchAction.addToList),
            MenuEntry(WatchAction.remove),
          ];
        case Status.dropped:
        case Status.done:
          return const [
            MenuEntry(WatchAction.watching),
            MenuEntry(WatchAction.watchedNow),
            MenuEntry(WatchAction.addToList),
            MenuEntry(WatchAction.remove),
          ];
      }

    case MediaType.series:
      final now = DateTime.now();
      final canMark = episodes.any((e) => !e.watched && isAired(e, now));
      final started = episodes.any((e) => e.watched);
      final markNote = canMark
          ? null
          : (started ? "You're up to date" : 'Nothing has aired yet');
      return [
        MenuEntry(WatchAction.addToWant, enabled: item.isDraft),
        MenuEntry(WatchAction.addToList),
        MenuEntry(WatchAction.watchedNow, enabled: canMark, note: markNote),
        MenuEntry(WatchAction.watchedEarlier, enabled: canMark, note: markNote),
        MenuEntry(
          WatchAction.unwatched,
          enabled: started,
          note: started ? null : 'No episode is marked yet',
        ),
        MenuEntry(WatchAction.remove, enabled: !item.isDraft),
      ];
  }
}

String actionLabel(MediaItem item, WatchAction a) {
  final book = item.type == MediaType.book;
  final series = item.type == MediaType.series;
  final done = item.status == Status.done && !item.isDraft;
  switch (a) {
    case WatchAction.addToWant:
      return statusLabel(item.type, Status.want);
    case WatchAction.watching:
      if (!book) return 'Watching';
      return done ? 'Reading again' : 'Reading';
    case WatchAction.watchedNow:
      if (series) return 'Mark aired episodes watched now';
      if (book) return done ? 'Read again now' : 'Read now';
      return done ? 'Watched again now' : 'Watched now';
    case WatchAction.watchedEarlier:
      if (series) return 'Mark aired episodes watched earlier';
      return book ? 'Read earlier' : 'Watched earlier';
    case WatchAction.backToWant:
      return book ? 'Back to Want to read' : 'Back to Want to watch';
    case WatchAction.unwatched:
      return 'Mark all episodes unwatched';
    case WatchAction.updateProgress:
      return 'Update progress';
    case WatchAction.didNotComplete:
      return 'Did not complete';
    case WatchAction.addToList:
      return 'Add to list';
    case WatchAction.remove:
      return 'Remove from Bookmark';
  }
}

String? actionHint(MediaItem item, WatchAction a) {
  final book = item.type == MediaType.book;
  switch (a) {
    case WatchAction.watchedNow:
      return book
          ? 'Counts in your reading stats'
          : 'Counts in your watch time';
    case WatchAction.watchedEarlier:
      return book
          ? 'Not counted in your reading stats'
          : 'Not counted in your watch time';
    default:
      return null;
  }
}

IconData actionIcon(WatchAction a) => switch (a) {
  WatchAction.addToWant => Icons.bookmark_add_outlined,
  WatchAction.watching => Icons.play_circle_outline,
  WatchAction.watchedNow => Icons.check_circle_outline,
  WatchAction.watchedEarlier => Icons.history,
  WatchAction.backToWant => Icons.bookmark_add_outlined,
  WatchAction.unwatched => Icons.undo,
  WatchAction.updateProgress => Icons.trending_up,
  WatchAction.didNotComplete => Icons.block,
  WatchAction.addToList => Icons.playlist_add,
  WatchAction.remove => Icons.delete_outline,
};

Future<void> showWatchMenu(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    List<Episode> episodes,
    ) async {
  final entries = menuFor(item, episodes);

  final picked = await showModalBottomSheet<WatchAction>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final text = Theme.of(sheetContext).textTheme;
      final scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                  Text(
                    item.isDraft
                        ? 'Not in your library yet'
                        : 'Status: ${statusLabel(item.type, item.status)}',
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            for (final e in entries)
              Builder(builder: (_) {
                final subtitle = e.note ?? actionHint(item, e.action);
                return ListTile(
                  enabled: e.enabled,
                  leading: Icon(
                    actionIcon(e.action),
                    color: (e.action == WatchAction.remove && e.enabled)
                        ? scheme.error
                        : null,
                  ),
                  title: Text(
                    actionLabel(item, e.action),
                    style: (e.action == WatchAction.remove && e.enabled)
                        ? TextStyle(color: scheme.error)
                        : null,
                  ),
                  subtitle: subtitle == null ? null : Text(subtitle),
                  onTap: e.enabled
                      ? () => Navigator.of(sheetContext).pop(e.action)
                      : null,
                );
              }),
          ],
        ),
      );
    },
  );

  if (picked != null && context.mounted) {
    await runWatchAction(context, ref, item, picked, episodes: episodes);
  }
}

Future<MediaItem?> _saveDraft(WidgetRef ref, MediaItem draft) async {
  final db = ref.read(databaseProvider);
  await ref.read(repositoryProvider).add(resultFromDraft(draft), Status.want);
  final id = await db.findId(draft.type, draft.externalId);
  if (id == null) return null;
  return db.watchItem(id).first;
}

Future<void> runWatchAction(
    BuildContext context,
    WidgetRef ref,
    MediaItem original,
    WatchAction action, {
      List<Episode> episodes = const [],
    }) async {
  final cover = original.isDraft && original.type == MediaType.series;
  final saving = ref.read(draftSavingProvider.notifier);
  if (cover) saving.set(true);
  try {
    await _runWatchAction(context, ref, original, action, episodes: episodes);
  } finally {
    if (cover) saving.set(false);
  }
}

Future<void> _runWatchAction(
    BuildContext context,
    WidgetRef ref,
    MediaItem original,
    WatchAction action, {
      List<Episode> episodes = const [],
    }) async {
  final db = ref.read(databaseProvider);
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);

  ProgressResult? progress;
  if (action == WatchAction.watching && original.type == MediaType.book) {
    progress = await askProgress(context, ref, original, starting: true);
    if (progress == null || !context.mounted) return;
  }

  var item = original;
  var eps = episodes;
  if (original.isDraft) {
    try {
      final saved = await _saveDraft(ref, original);
      if (saved == null) return;
      item = saved;
      if (item.type == MediaType.series) eps = await db.episodesOf(item.id);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Could not add it. Check your connection and try again.'),
      ));
      return;
    }
    if (!context.mounted) return;
  }

  final series = item.type == MediaType.series;
  final book = item.type == MediaType.book;
  final now = DateTime.now();
  final todo = eps.where((e) => !e.watched && isAired(e, now)).toList();

  switch (action) {
    case WatchAction.addToWant:
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Added "${item.title}" to ${statusLabel(item.type, Status.want)}',
        ),
      ));

    case WatchAction.watching:
      final p = progress;
      if (p != null) {
        await db.saveProgress(
          item.id,
          unit: p.unit,
          pageCount: p.pageCount,
          value: p.value,
        );
      } else {
        await db.setStatus(item.id, Status.inProgress);
      }

    case WatchAction.watchedNow:
    case WatchAction.watchedEarlier:
      final counted = action == WatchAction.watchedNow;
      if (series) {
        if (todo.isEmpty) {
          messenger.showSnackBar(SnackBar(
            content: Text(eps.any((e) => e.watched)
                ? "You're up to date."
                : 'Nothing has aired yet.'),
          ));
          return;
        }
        await db.setEpisodesWatched(
          item.id,
          todo.map((e) => e.id),
          true,
          counted: counted,
        );
      } else if (book) {
        await db.markBookRead(item.id, counted: counted);
      } else {
        await db.markDone(item, counted: counted);
      }

    case WatchAction.backToWant:
      final okWant = await confirmDialog(
        context,
        title: book ? 'Back to Want to read?' : 'Back to Want to watch?',
        message:
        'All history for "${item.title}" will be deleted, and it will no longer count in your stats.',
        yes: 'Delete history',
      );
      if (!okWant) return;
      await db.resetToWant(item.id);

    case WatchAction.unwatched:
      final okUnmark = await confirmDialog(
        context,
        title: 'Mark all episodes unwatched?',
        message: 'All episodes will be unticked and removed from your watch history.',
        yes: 'Unmark',
      );
      if (!okUnmark) return;
      await db.clearSeriesProgress(item.id);

    case WatchAction.updateProgress:
      await updateProgressFlow(context, ref, item);

    case WatchAction.didNotComplete:
      final result = await showDropSheet(
        context,
        reason: item.dropReason,
        page: item.droppedAtPage ?? item.pagesNow,
        pageCount: item.pageCount,
      );
      if (result != null) await db.setDropped(item.id, result.reason, result.page);

    case WatchAction.addToList:
      ref.read(draftSavingProvider.notifier).set(false);
      await showAddToListSheet(context, item);

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

Future<void> tapTick(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    List<Episode> episodes,
    ) async {
  if (item.type == MediaType.series) return;
  final db = ref.read(databaseProvider);
  final book = item.type == MediaType.book;

  switch (item.status) {
    case Status.want:
      if (book) {
        await startReading(context, ref, item);
      } else {
        await db.markDone(item, counted: true);
      }
    case Status.inProgress:
      await db.markBookRead(item.id, counted: true);
    case Status.dropped:
      await startReading(context, ref, item);
    case Status.done:
      await runWatchAction(context, ref, item, WatchAction.backToWant);
  }
}