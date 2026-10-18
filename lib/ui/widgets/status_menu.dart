import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../data/labels.dart';
import '../../providers.dart';

const _removeValue = 'remove';

/// Status dropdown for a detail page. The last menu item removes the item.
class StatusMenuButton extends ConsumerWidget {
  const StatusMenuButton({
    super.key,
    required this.item,
    required this.choices,
    this.onStatus,
  });

  final MediaItem item;
  final List<Status> choices;

  /// Custom handling when a status is picked (the book page needs this).
  /// By default the status is just saved.
  final Future<void> Function(Status status)? onStatus;

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final router = GoRouter.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Bookmark?'),
        content: Text('"${item.title}" and its progress will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    router.pop();
    await db.deleteItem(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = scheme.onSecondaryContainer;

    return PopupMenuButton<Object>(
      tooltip: 'Change status',
      onSelected: (value) {
        if (value is Status) {
          final save = onStatus ??
                  (Status s) => ref.read(databaseProvider).setStatus(item.id, s);
          save(value);
        } else {
          _confirmRemove(context, ref);
        }
      },
      itemBuilder: (_) => [
        for (final s in choices)
          CheckedPopupMenuItem<Object>(
            value: s,
            checked: item.status == s,
            child: Text(statusLabel(item.type, s)),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<Object>(
          value: _removeValue,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: scheme.error),
              const SizedBox(width: 12),
              Text('Remove from Bookmark', style: TextStyle(color: scheme.error)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusLabel(item.type, item.status),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: foreground),
            ),
            Icon(Icons.arrow_drop_down, color: foreground),
          ],
        ),
      ),
    );
  }
}