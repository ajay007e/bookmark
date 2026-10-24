import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

/// Scaffold now sizes the body above the bar, so screens only need a small gap.
double navBarClearance(BuildContext context) => 16;

class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Overrides the package's internal sizes so the selected icon is lifted
/// into the bump but is NOT bigger than the other icons.
class _NavStyle extends StyleHook {
  @override
  double get activeIconSize => 24; // same as iconSize, so no growing

  @override
  double get activeIconMargin => 14; // space around the lifted icon

  @override
  double? get iconSize => 24;

  @override
  TextStyle textStyle(Color color, String? fontFamily) =>
      TextStyle(fontSize: 12, color: color, fontFamily: fontFamily);
}

/// The bottom bar, built with the convex_bottom_bar package.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return StyleProvider(
      style: _NavStyle(),
      child: ConvexAppBar(
        style: TabStyle.react, // the bump from your picture
        initialActiveIndex: selectedIndex,
        onTap: onSelected,
        backgroundColor: scheme.surfaceContainerHigh, // theme colours, as before
        color: scheme.onSurfaceVariant, // unselected icons
        activeColor: scheme.primary, // selected icon
        height: 60,
        top: -16, // how high the bump rises
        curveSize: 80, // width of the bump
        elevation: 8,
        items: [
          // No titles, so only icons show.
          for (final i in items) TabItem(icon: i.icon, activeIcon: i.selectedIcon),
        ],
      ),
    );
  }
}