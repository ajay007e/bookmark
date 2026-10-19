import 'package:flutter/material.dart';

/// "Name (year)" with a button on the right. The button never makes the row
/// taller than the title, so the content below stays close to the title.
class TitleRow extends StatelessWidget {
  const TitleRow({
    super.key,
    required this.title,
    this.year,
    required this.trailing,
  });

  final String title;
  final int? year;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: title,
                children: [
                  if (year != null)
                    TextSpan(
                      text: ' ($year)',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              style: text.headlineMedium,
            ),
          ),
          const SizedBox(width: 12),
          // A 36px slot: the button may overhang it slightly without
          // pushing anything down.
          SizedBox(
            width: 40,
            height: 36,
            child: OverflowBox(
              minHeight: 0,
              maxHeight: 44,
              alignment: Alignment.topCenter,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}