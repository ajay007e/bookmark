import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/search_result.dart';
import '../data/app_database.dart';
import '../providers.dart';
import 'book_detail_view.dart';
import 'draft_item.dart';
import 'movie_detail_view.dart';
import 'series_detail_view.dart';

/// The detail page. Opened with a saved item's id, or with a search result
/// (`ItemDetailScreen.preview`) for something that is not in the library yet.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.id}) : result = null;

  const ItemDetailScreen.preview({super.key, required this.result}) : id = null;

  final int? id;
  final SearchResult? result;

  Widget _view(MediaItem item) => switch (item.type) {
    MediaType.movie => MovieDetailView(item: item),
    MediaType.book => BookDetailView(item: item),
    MediaType.series => SeriesDetailView(item: item),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = result;

    if (preview != null) {
      // Show a draft until the item is saved. The moment it is saved, the same
      // page shows the saved item, so the scroll position and tabs stay put.
      final saved = ref.watch(itemsByTypeProvider(preview.type)).maybeWhen<MediaItem?>(
        data: (list) =>
        list.where((i) => i.externalId == preview.externalId).firstOrNull,
        orElse: () => null,
      );
      return _view(saved ?? draftFromResult(preview));
    }

    final item = ref.watch(itemProvider(id!));
    return item.when(
      data: (item) {
        // null happens for a moment after the item is deleted
        if (item == null) return const Scaffold();
        return _view(item);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Something went wrong: $e'))),
    );
  }
}