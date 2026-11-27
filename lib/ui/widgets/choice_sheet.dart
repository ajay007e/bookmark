import 'package:flutter/material.dart';

class ChoiceOption<T> {
  const ChoiceOption(this.value, this.title, [this.subtitle]);

  final T value;
  final String title;
  final String? subtitle;
}

Future<T?> showChoiceSheet<T>(
    BuildContext context, {
      required String title,
      String? note,
      required List<ChoiceOption<T>> options,
      required T current,
    }) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      final text = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(title, style: text.titleLarge),
              ),
              if (note != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    note,
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              for (final o in options)
                ListTile(
                  selected: o.value == current,
                  title: Text(o.title),
                  subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                  trailing: o.value == current
                      ? Icon(Icons.check_circle, color: scheme.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(o.value),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}