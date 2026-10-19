import 'package:flutter/material.dart';

/// "Director" over "Christopher Nolan".
class CreditBlock extends StatelessWidget {
  const CreditBlock({super.key, required this.label, required this.names});

  final String label;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.titleSmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(names.join(', '), style: text.bodyLarge),
      ],
    );
  }
}