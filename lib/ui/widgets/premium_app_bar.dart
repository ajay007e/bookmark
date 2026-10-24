import 'package:flutter/material.dart';

const double _barBody = 80;

const _weekdays = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
const _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

String _today() {
  final d = DateTime.now();
  return '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';
}

/// An editorial top bar: small eyebrow line, big gradient title, glass buttons.
/// [eyebrow] defaults to today's date.
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumAppBar({
    super.key,
    required this.title,
    this.eyebrow,
    this.actions = const [],
  });

  final String title;
  final String? eyebrow;
  final List<Widget> actions;

  /// The Scaffold needs the height up front, so the status bar height is added here.
  @override
  Size get preferredSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return Size.fromHeight(_barBody + view.padding.top / view.devicePixelRatio);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: _barBody,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow ?? _today(),
                      style: text.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (rect) => LinearGradient(
                        colors: [scheme.onSurface, scheme.primary],
                      ).createShader(rect),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1.05,
                          color: Colors.white, // replaced by the gradient
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (final a in actions) ...[const SizedBox(width: 10), a],
            ],
          ),
        ),
      ),
    );
  }
}

/// A round glass button with a hairline border, for the top bar.
class AppBarAction extends StatelessWidget {
  const AppBarAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
        shape: CircleBorder(
          side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.12)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 22, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}