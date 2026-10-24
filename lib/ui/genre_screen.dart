import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'widgets/empty_state.dart';
import 'widgets/poster_card.dart';

String _typeLabel(MediaType t) => switch (t) {
  MediaType.movie => 'Movies',
  MediaType.series => 'Series',
  MediaType.book => 'Books',
};

/// Everything in the library with one genre, across movies, series and books.
class GenreScreen extends ConsumerStatefulWidget {
  const GenreScreen({super.key, required this.genre});

  final String genre;

  @override
  ConsumerState<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends ConsumerState<GenreScreen> {
  MediaType? _type; // null = all

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsByGenreProvider(widget.genre));

    return Scaffold(
      appBar: AppBar(title: Text(widget.genre)),
      body: items.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              compact: true,
              title: 'Nothing here',
              message: 'No item in your library has this genre.',
            );
          }

          // Only offer type filters that have something in them.
          final types = MediaType.values
              .where((t) => list.any((i) => i.type == t))
              .toList();
          final active = types.contains(_type) ? _type : null;
          final shown =
          active == null ? list : list.where((i) => i.type == active).toList();

          return Column(
            children: [
              if (types.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      _chip('All', active == null, () => setState(() => _type = null)),
                      for (final t in types)
                        _chip(_typeLabel(t), active == t, () => setState(() => _type = t)),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
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
                  itemCount: shown.length,
                  itemBuilder: (_, i) => PosterCard(item: shown[i]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}