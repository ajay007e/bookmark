import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/labels.dart';
import '../providers.dart';
import 'widgets/poster_card.dart';

/// Shows all books, movies or series, with a status filter.
class MediaListScreen extends ConsumerStatefulWidget {
  const MediaListScreen({super.key, required this.type});

  final MediaType type;

  @override
  ConsumerState<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends ConsumerState<MediaListScreen> {
  Status? _filter;

  String get _title => switch (widget.type) {
    MediaType.book => 'Books',
    MediaType.movie => 'Movies',
    MediaType.series => 'Series',
  };

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsByTypeProvider(widget.type));
    final statuses = widget.type == MediaType.book
        ? Status.values
        : Status.values.where((s) => s != Status.dropped).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _chip('All', _filter == null, () => setState(() => _filter = null)),
                for (final s in statuses)
                  _chip(
                    statusLabel(widget.type, s),
                    _filter == s,
                        () => setState(() => _filter = s),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.when(
              data: (list) {
                final shown = _filter == null
                    ? list
                    : list.where((i) => i.status == _filter).toList();
                if (shown.isEmpty) {
                  return const Center(child: Text('Nothing here yet'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (_, i) => PosterCard(item: shown[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Something went wrong: $e')),
            ),
          ),
        ],
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