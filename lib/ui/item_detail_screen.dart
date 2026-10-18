import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'book_detail_view.dart';
import 'movie_detail_view.dart';
import 'series_detail_view.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemProvider(id));

    return item.when(
      data: (item) {
        // null happens for a moment after the item is deleted
        if (item == null) return const Scaffold();
        return switch (item.type) {
          MediaType.movie => MovieDetailView(item: item),
          MediaType.book => BookDetailView(item: item),
          MediaType.series => SeriesDetailView(item: item),
        };
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Something went wrong: $e'))),
    );
  }
}