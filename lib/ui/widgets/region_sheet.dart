import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/region_provider.dart';

/// A scrollable list of countries. Tapping one saves it and closes the sheet.
Future<void> showRegionSheet(BuildContext context, WidgetRef ref) {
  final current = ref.read(regionProvider).asData?.value ?? defaultRegion;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      final text = Theme.of(sheetContext).textTheme;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Text('Streaming region', style: text.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Sets where "Watch now" looks, and which age rating and release date are shown first.',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: regions.length,
                itemBuilder: (_, i) {
                  final r = regions[i];
                  final selected = r.code == current;
                  return ListTile(
                    selected: selected,
                    title: Text(r.name),
                    subtitle: Text(r.code),
                    trailing: selected
                        ? Icon(Icons.check_circle, color: scheme.primary)
                        : null,
                    onTap: () {
                      ref.read(regionProvider.notifier).set(r.code);
                      Navigator.of(sheetContext).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}