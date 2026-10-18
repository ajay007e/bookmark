import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small animated illustration: a stack of books, a clapperboard and a
/// floating bookmark. Drawn with plain widgets, so it follows the app theme
/// (light and dark) and needs no asset files.
class BookmarkIllustration extends StatefulWidget {
  const BookmarkIllustration({super.key, this.size = 200});

  final double size;

  @override
  State<BookmarkIllustration> createState() => _BookmarkIllustrationState();
}

class _BookmarkIllustrationState extends State<BookmarkIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final scheme = Theme.of(context).colorScheme;

    Widget spine(double h, Color color) => Container(
      width: s * 0.1,
      height: h,
      margin: EdgeInsets.only(right: s * 0.025),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(s * 0.02),
      ),
    );

    return SizedBox(
      width: s,
      height: s * 0.9,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft background circle
              Container(
                width: s * 0.85,
                height: s * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer.withValues(alpha: 0.55),
                ),
              ),
              // Books
              Positioned(
                left: s * 0.17,
                bottom: s * 0.14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    spine(s * 0.36, scheme.primary),
                    spine(s * 0.45, scheme.tertiary),
                    spine(s * 0.31, scheme.secondary),
                  ],
                ),
              ),
              // Clapperboard, floating the other way
              Positioned(
                right: s * 0.12,
                bottom: s * 0.16 + 5 * (1 - t),
                child: Transform.rotate(
                  angle: 6 * math.pi / 180,
                  child: Container(
                    width: s * 0.3,
                    height: s * 0.3,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(s * 0.05),
                      border: Border.all(color: scheme.secondary, width: 2),
                    ),
                    child: Icon(
                      Icons.movie_outlined,
                      size: s * 0.16,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              // Bookmark ribbon
              Positioned(
                top: s * 0.02 + 8 * t,
                right: s * 0.3,
                child: Icon(Icons.bookmark, size: s * 0.34, color: scheme.error),
              ),
              // Sparkles
              Positioned(
                top: s * 0.16,
                left: s * 0.2,
                child: Opacity(
                  opacity: 0.4 + 0.6 * t,
                  child: Icon(Icons.auto_awesome, size: s * 0.1, color: scheme.primary),
                ),
              ),
              Positioned(
                top: s * 0.32,
                right: s * 0.1,
                child: Opacity(
                  opacity: 1 - 0.6 * t,
                  child: Icon(Icons.auto_awesome, size: s * 0.07, color: scheme.tertiary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}