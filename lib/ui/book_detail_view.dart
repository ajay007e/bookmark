import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/detail_info.dart';
import '../api/search_result.dart';
import '../data/app_database.dart';
import '../providers.dart';
import 'widgets/detail_header.dart';
import 'widgets/drop_sheet.dart';
import 'widgets/load_note.dart';
import 'widgets/meta_block.dart';
import 'widgets/section_divider.dart';
import 'widgets/similar_row.dart';
import 'widgets/title_row.dart';
import 'widgets/watch_tick.dart';

class BookDetailView extends ConsumerWidget {
  const BookDetailView({super.key, required this.item});

  final MediaItem item;

  /// Opens the reason and page sheet. Cancelling changes nothing.
  Future<void> _editDrop(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final result = await showDropSheet(
      context,
      reason: item.dropReason,
      page: item.droppedAtPage,
      pageCount: item.pageCount,
    );
    if (result == null) return;
    await db.setDropped(item.id, result.reason, result.page);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final info = ref.watch(bookInfoProvider(item.externalId));
    final loaded = info.maybeWhen<BookInfo?>(data: (i) => i, orElse: () => null);
    final similar = ref
        .watch(bookSimilarProvider(
        (key: item.externalId, title: item.title, author: item.author)))
        .maybeWhen<List<SearchResult>>(data: (l) => l, orElse: () => const []);

    final average = loaded?.ratingAverage;
    final hasScore = average != null && average > 0 && (loaded?.ratingCount ?? 0) > 0;

    final pages = item.pageCount ?? loaded?.pages;
    final language = loaded?.language;
    final publisher = loaded?.publisher;
    final line = [
      if (pages != null && pages > 0) '$pages pages',
      if (language != null) language,
      if (publisher != null) publisher,
    ].join(' · ');

    final subjects = (loaded != null && loaded.subjects.isNotEmpty)
        ? loaded.subjects
        : (item.genres.isEmpty ? <String>[] : item.genres.split(','));
    final description = loaded?.description ?? item.overview;
    final author = item.author;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailHeader(item: item),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleRow(
                    title: item.title,
                    year: item.year,
                    trailing: WatchTick(item: item),
                  ),
                  if (author != null && author.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('by $author', style: text.titleMedium),
                    ),
                  const SizedBox(height: 12),
                  MetaBlock(
                    score: hasScore ? average : null,
                    outOf: 5,
                    lines: [line],
                  ),
                  if (item.status == Status.dropped) ...[
                    const SizedBox(height: 16),
                    _DroppedCard(
                      reason: item.dropReason,
                      page: item.droppedAtPage,
                      onEdit: () => _editDrop(context, ref),
                    ),
                  ],
                  if (subjects.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final s in subjects)
                          Chip(label: Text(s), visualDensity: VisualDensity.compact),
                      ],
                    ),
                  ],
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('About this book', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(description, style: text.bodyLarge),
                  ],
                  LoadNote(state: info, what: 'book details'),
                  if (similar.isNotEmpty) ...[
                    const SectionDivider(bottom: 0),
                    SimilarRow(type: MediaType.book, items: similar),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DroppedCard extends StatelessWidget {
  const _DroppedCard({this.reason, this.page, required this.onEdit});

  final String? reason;
  final int? page;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final hasReason = reason != null && reason!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Did not complete', style: text.titleSmall),
                const SizedBox(height: 4),
                if (hasReason) Text('Reason: $reason', style: text.bodyMedium),
                if (page != null) Text('Stopped at page $page', style: text.bodyMedium),
                if (!hasReason && page == null)
                  Text('No reason or page added', style: text.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}