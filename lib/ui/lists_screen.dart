import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/list_card.dart';
import 'widgets/list_dialogs.dart';

/// The Lists segment: browse by genre, then your own lists.
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  /// How many of the most common genres show in the sideways row.
  static const _topCount = 8;

  void _openGenre(BuildContext context, String name) {
    context.push(
      Uri(path: '/genre', queryParameters: {'name': name}).toString(),
    );
  }

  /// A scrollable list of every genre.
  void _showAllGenres(BuildContext context, List<({String name, int count})> all) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'All genres',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: all.length,
                itemBuilder: (_, i) {
                  final g = all[i];
                  return ListTile(
                    title: Text(g.name),
                    trailing: Text(
                      '${g.count}',
                      style: Theme.of(sheetContext).textTheme.labelLarge,
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop(); // close the sheet first
                      _openGenre(context, g.name);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres = ref.watch(genreCountsProvider);
    final lists = ref.watch(listsProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(0, 8, 0, navBarClearance(context)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Browse by genre', style: text.titleMedium),
        ),
        const SizedBox(height: 12),
        genres.when(
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Genres appear here once you add movies, series or books.',
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              );
            }
            final top = list.take(_topCount).toList();
            return SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final g in top)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text('${g.name} · ${g.count}'),
                        onPressed: () => _openGenre(context, g.name),
                      ),
                    ),
                  if (list.length > _topCount)
                    ActionChip(
                      avatar: const Icon(Icons.expand_more_rounded, size: 18),
                      label: Text('All genres (${list.length})'),
                      onPressed: () => _showAllGenres(context, list),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Something went wrong: $e'),
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('My lists', style: text.titleMedium),
        ),
        const SizedBox(height: 12),
        lists.when(
          data: (all) => GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // the page scrolls, not the grid
            padding: const EdgeInsets.symmetric(horizontal: 16),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: [
              for (final e in all) ListCard(list: e.list, count: e.count),
              _NewListCard(onTap: () => createListFlow(context, ref)),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Something went wrong: $e'),
          ),
        ),
      ],
    );
  }
}

class _NewListCard extends StatelessWidget {
  const _NewListCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 36, color: scheme.primary),
            const SizedBox(height: 6),
            Text(
              'New list',
              style: text.titleSmall?.copyWith(color: scheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}