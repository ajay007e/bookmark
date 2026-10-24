import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import 'list_dialogs.dart';

/// A sheet with a checkbox for every list. Ticking adds the item at once.
Future<void> showAddToListSheet(BuildContext context, MediaItem item) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _AddToListSheet(item: item),
  );
}

class _AddToListSheet extends ConsumerWidget {
  const _AddToListSheet({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final lists = ref.watch(listsProvider);
    final member = ref.watch(itemListIdsProvider(item.id)).maybeWhen<Set<int>>(
      data: (s) => s,
      orElse: () => const <int>{},
    );
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Add to list', style: text.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: const Text('New list'),
              onTap: () async {
                final id = await createListFlow(context, ref);
                if (id != null) await db.setInList(id, item.id, true);
              },
            ),
            const Divider(height: 1),
            Flexible(
              child: lists.when(
                data: (all) {
                  if (all.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('You have no lists yet. Create one above.'),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      for (final e in all)
                        CheckboxListTile(
                          value: member.contains(e.list.id),
                          title: Text(e.list.name),
                          subtitle: Text(e.count == 1 ? '1 item' : '${e.count} items'),
                          onChanged: (v) =>
                              db.setInList(e.list.id, item.id, v ?? false),
                        ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Something went wrong: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}