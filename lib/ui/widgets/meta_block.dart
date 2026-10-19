import 'package:flutter/material.dart';

import 'score_badge.dart';

/// Rating ring | line 1 / line 2 ...  Empty lines are skipped.
class MetaBlock extends StatelessWidget {
  const MetaBlock({
    super.key,
    this.score,
    this.outOf = 10,
    required this.lines,
  });

  final double? score;
  final int outOf;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final shown = lines.where((l) => l.isNotEmpty).toList();
    if (score == null && shown.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        if (score != null) ...[
          ScoreBadge(value: score!, outOf: outOf),
          const SizedBox(width: 12),
          Container(width: 1, height: 40, color: scheme.outlineVariant),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < shown.length; i++)
                Text(shown[i], style: i == 0 ? text.bodyLarge : text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}