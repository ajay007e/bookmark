import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/search_result.dart';
import '../../data/app_database.dart';
import '../../providers.dart';
import '../search_screen.dart';
import 'poster_card.dart';

/// "You may also like". Tap an item you already have to open it,
/// or tap a new one to add it. As tall as its content.
class SimilarRow extends ConsumerWidget {
  const SimilarRow({super.key, required this.type, required this.items});

  final MediaType type;
  final List<SearchResult> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();

    // external id -> database id, for the items already in the library
    final owned = ref.watch(itemsByTypeProvider(type)).maybeWhen<Map<String, int>>(
      data: (list) => {for (final i in list) i.externalId: i.id},
      orElse: () => const <String, int>{},
    );
    final text = Theme.of(context).textTheme;

    Widget tile(SearchResult r) {
      final id = owned[r.externalId];
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (id != null) {
            context.push('/item/$id');
          } else {
            showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => AddSheet(result: r),
            );
          }
        },
        child: SizedBox(
          width: 110,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(type: r.type, title: r.title, url: r.posterUrl),
                      if (id != null)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 11,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.check, size: 14, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  r.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('You may also like', style: text.titleMedium),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                tile(items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}