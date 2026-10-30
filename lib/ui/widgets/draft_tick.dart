import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/labels.dart';
import '../../providers.dart';
import '../draft_item.dart';
import 'tick_circle.dart';

/// The tick for an item that is not in your library yet.
/// Tap = add it to Want. Nothing else is saved.
class DraftTick extends ConsumerStatefulWidget {
  const DraftTick({super.key, required this.item});

  final MediaItem item;

  @override
  ConsumerState<DraftTick> createState() => _DraftTickState();
}

class _DraftTickState extends ConsumerState<DraftTick> {
  bool _saving = false;

  Future<void> _add() async {
    final messenger = ScaffoldMessenger.of(context);
    final item = widget.item;
    final label = statusLabel(item.type, Status.want);

    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).add(resultFromDraft(item), Status.want);
      messenger.showSnackBar(
        SnackBar(content: Text('Added "${item.title}" to $label')),
      );
      // The page now switches to the saved item by itself.
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not add it. Check your connection and try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_saving) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(9),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    return Tooltip(
      message: 'Add to ${statusLabel(widget.item.type, Status.want)}',
      child: TickCircle(state: TickState.none, size: 40, onTap: _add),
    );
  }
}