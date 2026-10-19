import 'package:flutter/material.dart';

/// none = not started, active = watching or reading, done, dropped.
enum TickState { none, active, done, dropped }

/// The round tick used on detail pages and for episodes.
/// With no onTap and no onLongPress it looks disabled.
class TickCircle extends StatelessWidget {
  const TickCircle({
    super.key,
    required this.state,
    this.size = 40,
    this.activeIcon = Icons.play_arrow_rounded,
    this.onTap,
    this.onLongPress,
  });

  final TickState state;
  final double size;
  final IconData activeIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color border, Color fill, Color iconColor, IconData icon) =
    switch (state) {
      TickState.none => (scheme.outline, Colors.transparent, scheme.outline, Icons.check),
      TickState.active => (scheme.primary, Colors.transparent, scheme.primary, activeIcon),
      TickState.done => (scheme.primary, scheme.primary, scheme.onPrimary, Icons.check),
      TickState.dropped => (scheme.error, Colors.transparent, scheme.error, Icons.block),
    };

    final enabled = onTap != null || onLongPress != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: fill,
        shape: CircleBorder(side: BorderSide(color: border, width: 2)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          onLongPress: onLongPress,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: iconColor, size: size * 0.55),
          ),
        ),
      ),
    );
  }
}