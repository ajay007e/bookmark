import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/accent_provider.dart';

/// One scrollable row of colour circles. Tap one to change the accent colour.
class AccentPicker extends ConsumerWidget {
  const AccentPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(accentProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Accent colour', style: text.titleMedium),
                const Spacer(),
                Text(selected.name, style: text.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // A horizontal list never wraps onto a new line, it scrolls sideways.
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: accentOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final option = accentOptions[i];
                final isSelected = option.id == selected.id;

                return Center(
                  child: Tooltip(
                    message: option.name,
                    child: GestureDetector(
                      onTap: () => ref.read(accentProvider.notifier).set(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: option.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? scheme.onSurface : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}