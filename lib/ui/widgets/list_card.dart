import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import 'poster_card.dart';

/// A list as a card: poster collage, name and item count.
class ListCard extends ConsumerWidget {
  const ListCard({super.key, required this.list, required this.count});

  final UserList list;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final items = ref
        .watch(listItemsProvider(list.id))
        .maybeWhen<List<MediaItem>>(data: (l) => l, orElse: () => const []);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/list/${list.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _Collage(items: items.take(4).toList()),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            list.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(count == 1 ? '1 item' : '$count items', style: text.bodySmall),
        ],
      ),
    );
  }
}

class _Collage extends StatelessWidget {
  const _Collage({required this.items});

  final List<MediaItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.collections_bookmark_outlined,
              size: 36, color: scheme.onSurfaceVariant),
        ),
      );
    }
    if (items.length == 1) return PosterImage.fromItem(items[0]);

    Widget cell(int i) => i < items.length
        ? PosterImage.fromItem(items[i])
        : ColoredBox(color: scheme.surfaceContainerHighest);

    return Column(
      children: [
        Expanded(
          child: Row(children: [
            Expanded(child: cell(0)),
            const SizedBox(width: 2),
            Expanded(child: cell(1)),
          ]),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(children: [
            Expanded(child: cell(2)),
            const SizedBox(width: 2),
            Expanded(child: cell(3)),
          ]),
        ),
      ],
    );
  }
}