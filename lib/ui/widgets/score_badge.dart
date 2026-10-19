import 'package:flutter/material.dart';

/// A ring that fills according to the score, with the number in the middle.
/// Green is high, amber is middling, red is low.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    super.key,
    required this.value,
    required this.outOf,
    this.size = 46,
  });

  final double value;
  final int outOf;
  final double size;

  Color get _color {
    final ratio = value / outOf;
    if (ratio >= 0.7) return Colors.green;
    if (ratio >= 0.5) return Colors.amber.shade700;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Tooltip(
      message: 'Rating ${value.toStringAsFixed(1)} out of $outOf',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: (value / outOf).clamp(0.0, 1.0),
              strokeWidth: size < 36 ? 3 : 4,
              color: color,
              backgroundColor: color.withValues(alpha: 0.25),
            ),
            Center(
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}