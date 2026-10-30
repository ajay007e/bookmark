import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/labels.dart';
import '../../providers.dart';
import '../draft_item.dart';
import '../watch_actions.dart';
import 'tick_circle.dart';

/// The round tick next to the title.
/// - Not in your library: tap adds it to Want, long press shows the options.
/// - Movie or book: tap moves it along (see [tapTick]), long press shows the options.
/// - Series: a status icon only. The status follows the episodes.
class WatchTick extends ConsumerStatefulWidget {
  const WatchTick({super.key, required this.item, this.episodes = const []});

  final MediaItem item;
  final List<Episode> episodes;

  @override
  ConsumerState<WatchTick> createState() => _WatchTickState();
}

class _WatchTickState extends ConsumerState<WatchTick> {
  bool _busy = false;

  TickState get _state => switch (widget.item.status) {
    Status.want => TickState.none,
    Status.inProgress => TickState.active,
    Status.done => TickState.done,
    Status.dropped => TickState.dropped,
  };

  Future<void> _add() async {
    final messenger = ScaffoldMessenger.of(context);
    final item = widget.item;
    final label = statusLabel(item.type, Status.want);

    setState(() => _busy = true);
    try {
      await ref.read(repositoryProvider).add(resultFromDraft(item), Status.want);
      messenger.showSnackBar(
        SnackBar(content: Text('Added "${item.title}" to $label')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not add it. Check your connection and try again.'),
        ),
      );
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    if (_busy) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(9),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    // Not in the library yet
    if (item.isDraft) {
      return Tooltip(
        message: 'Add to ${statusLabel(item.type, Status.want)}',
        child: TickCircle(
          state: TickState.none,
          size: 40,
          onTap: _add,
          onLongPress: () => showWatchMenu(context, ref, item, widget.episodes),
        ),
      );
    }

    // Series: shows the status, cannot be pressed.
    if (item.type == MediaType.series) {
      return Tooltip(
        message: '${statusLabel(item.type, item.status)} (follows your episodes)',
        child: TickCircle(state: _state, size: 40),
      );
    }

    return Semantics(
      label: statusLabel(item.type, item.status),
      child: TickCircle(
        state: _state,
        size: 40,
        activeIcon: item.type == MediaType.book
            ? Icons.auto_stories
            : Icons.play_arrow_rounded,
        onTap: () => tapTick(context, ref, item, widget.episodes),
        onLongPress: () => showWatchMenu(context, ref, item, widget.episodes),
      ),
    );
  }
}