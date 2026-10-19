import 'package:flutter/material.dart';

/// The line between sections (Cast, Similar, ...), with even spacing.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key, this.bottom = 20});

  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 20, bottom: bottom),
    child: const Divider(height: 1),
  );
}