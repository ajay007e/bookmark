import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'series_actions.dart';
import 'widgets/empty_state.dart';
import 'widgets/list_dialogs.dart';
import 'widgets/poster_card.dart';

/// One custom list: its items in a grid. Long-press an item to remove it.
class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.id});

  final int id;

  Future<void> _rename(BuildContext context, WidgetRef ref, UserList list) async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    final name = await askListName(
      context,
      title: 'Rename list',
      confirm: 'Save',
      initial: list.name,
    );
    if (name == null) return;
    final ok = await db.renameList(list.id, name);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a name that is not already used.')),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, UserList list) async {
    final db = ref.read(databaseProvider);
    final router = GoRouter.of(context);
    final ok = await confirmDialog(
      context,
      title: 'Delete this list?',
      message: '"${list.name}" will be deleted. The items stay in your library.',
      yes: 'Delete',
    );
    if (!ok) return;
    router.pop();
    await db.deleteList(list.id);
  }

  Future<void> _removeItem(BuildContext context, WidgetRef ref, MediaItem item) async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    final remove = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from this list'),
              subtitle: const Text('It stays in your library'),
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    if (remove != true) return;
    await db.setInList(id, item.id, false);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Removed "${item.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => db.setInList(id, item.id, true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(listProvider(id)).maybeWhen<UserList?>(
      data: (l) => l,
      orElse: () => null,
    );
    final items = ref.watch(listItemsProvider(id));

    // null happens for a moment after the list is deleted
    if (list == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'rename') _rename(context, ref, list);
              if (v == 'delete') _delete(context, ref, list);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename list')),
              PopupMenuItem(value: 'delete', child: Text('Delete list')),
            ],
          ),
        ],
      ),
      body: items.when(
        data: (all) {
          if (all.isEmpty) {
            return const EmptyState(
              compact: true,
              title: 'This list is empty',
              message:
              'Open a movie, series or book, press and hold its tick button, '
                  'and choose "Add to list".',
            );
          }
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemCount: all.length,
            itemBuilder: (_, i) => GestureDetector(
              onLongPress: () => _removeItem(context, ref, all[i]),
              child: PosterCard(item: all[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
      ),
    );
  }
}