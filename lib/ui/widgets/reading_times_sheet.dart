import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/reading_settings.dart';
import '../../settings/reading_settings_provider.dart';

Future<void> showReadingTimesSheet(BuildContext context, WidgetRef ref) async {
  final current = await ref.read(readingSettingsProvider.future);
  if (!context.mounted) return;

  final picked = await showModalBottomSheet<ReadingSettings>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TimesSheet(initial: current),
  );
  if (picked != null) {
    await ref.read(readingSettingsProvider.notifier).save(picked);
  }
}

class _TimesSheet extends StatefulWidget {
  const _TimesSheet({required this.initial});

  final ReadingSettings initial;

  @override
  State<_TimesSheet> createState() => _TimesSheetState();
}

class _TimesSheetState extends State<_TimesSheet> {
  late int _checkIn = widget.initial.checkInMinutes;
  late int _answer = widget.initial.answerMinutes;

  Widget _choices(List<int> values, int selected, ValueChanged<int> onPick) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final m in values)
          ChoiceChip(
            label: Text(minutesLabel(m)),
            selected: selected == m,
            onSelected: (_) => onPick(m),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Check-in timing', style: text.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Applies to the next reading session. The alarm uses your phone\'s default alarm sound.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text('Check-in every', style: text.titleSmall),
            const SizedBox(height: 8),
            _choices(checkInChoices, _checkIn, (m) => setState(() => _checkIn = m)),
            const SizedBox(height: 20),
            Text('Time to answer', style: text.titleSmall),
            const SizedBox(height: 8),
            _choices(answerChoices, _answer, (m) => setState(() => _answer = m)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      ReadingSettings(
                        checkInMinutes: _checkIn,
                        answerMinutes: _answer,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}