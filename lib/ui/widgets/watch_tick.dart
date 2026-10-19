import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/labels.dart';
import '../watch_actions.dart';
import 'tick_circle.dart';

/// Round tick button. Tap = watched now. Long press = more options.
/// Pass the series' episodes for series pages.
class WatchTick extends ConsumerWidget {
  const WatchTick({super.key, required this.item, this.episodes = const []});

  final MediaItem item;
  final List<Episode> episodes;

  TickState get _state => switch (item.status) {
    Status.want => TickState.none,
    Status.inProgress => TickState.active,
    Status.done => TickState.done,
    Status.dropped => TickState.dropped,
  };

  void _showMenu(BuildContext context, WidgetRef ref) {
    final actions = menuFor(item, episodes);
    showModalBottomSheet<WatchAction>(
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
                      'Status: ${statusLabel(item.type, item.status)}',
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              for (final a in actions)
                ListTile(
                  leading: Icon(
                    actionIcon(a),
                    color: a == WatchAction.remove ? scheme.error : null,
                  ),
                  title: Text(
                    actionLabel(item, a),
                    style: a == WatchAction.remove
                        ? TextStyle(color: scheme.error)
                        : null,
                  ),
                  subtitle: actionHint(a) == null ? null : Text(actionHint(a)!),
                  onTap: () => Navigator.of(sheetContext).pop(a),
                ),
            ],
          ),
        );
      },
    ).then((picked) {
      if (picked != null && context.mounted) {
        runWatchAction(context, ref, item, picked, episodes: episodes);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: statusLabel(item.type, item.status),
      child: TickCircle(
        state: _state,
        size: 40,
        activeIcon: item.type == MediaType.book
            ? Icons.auto_stories
            : Icons.play_arrow_rounded,
        onTap: () => tapTick(context, ref, item, episodes),
        onLongPress: () => _showMenu(context, ref),
      ),
    );
  }
}