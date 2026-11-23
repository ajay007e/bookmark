import 'package:flutter/material.dart';

class TitleRow extends StatelessWidget {
  const TitleRow({
    super.key,
    required this.title,
    this.year,
    required this.trailing,
    this.trailingWidth = 40,
  });

  final String title;
  final int? year;
  final Widget trailing;
  final double trailingWidth;

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
          SizedBox(
            width: trailingWidth,
            height: 36,
            child: OverflowBox(
              minHeight: 0,
              maxHeight: 44,
              alignment: Alignment.topRight,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}