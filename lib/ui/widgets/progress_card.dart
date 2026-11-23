import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/reading_queries.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.item, required this.onUpdate});

  final MediaItem item;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final pages = item.unit == ProgressUnit.pages;

    final headline =
    pages ? 'Page ${item.currentPage} of ${item.pageCount}' : '${item.currentPage}%';
    final detail = pages
        ? '${item.percentDone}%'
        : (item.hasPages
        ? 'About page ${item.pagesNow ?? 0} of ${item.pageCount}'
        : null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress', style: text.titleSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: Text(headline, style: text.titleMedium)),
              if (detail != null) Text(detail, style: text.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: item.progressMax == 0
                  ? 0
                  : (item.currentPage / item.progressMax).clamp(0.0, 1.0),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: onUpdate,
              child: const Text('Update progress'),
            ),
          ),
        ],
      ),
    );
  }
}