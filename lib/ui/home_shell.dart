import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'contents_screen.dart';
import 'home_screen.dart';
import 'widgets/app_nav_bar.dart';
import 'you_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    ContentsScreen(),
    YouScreen(),
  ];

  static const _items = <AppNavItem>[
    AppNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    AppNavItem(
      label: 'Contents',
      icon: Icons.collections_bookmark_outlined,
      selectedIcon: Icons.collections_bookmark_rounded,
    ),
    AppNavItem(
      label: 'You',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every tab alive, so scroll positions survive.
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppNavBar(
        items: _items,
        selectedIndex: _index,
        onSelected: (i) {
          if (i == _index) return;
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
      ),
    );
  }
}