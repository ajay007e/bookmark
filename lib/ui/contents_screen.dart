import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_database.dart';
import 'lists_screen.dart';
import 'media_list_screen.dart';
import 'search_screen.dart';
import 'widgets/pill_segments.dart';
import 'widgets/premium_app_bar.dart';

/// The Contents tab: Movies, Series, Books and Lists as swipeable segments.
class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  static const _labels = ['Movies', 'Series', 'Books', 'Lists'];

  final _pages = PageController();
  int _index = 0;
  bool _animating = false; // true while a tap-triggered slide is running

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// The type the "+" button adds. Null on Lists.
  MediaType? get _type => switch (_index) {
    0 => MediaType.movie,
    1 => MediaType.series,
    2 => MediaType.book,
    _ => null,
  };

  Future<void> _select(int i) async {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    _animating = true;
    await _pages.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    _animating = false;
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Contents',
        actions: [
          if (type != null)
            AppBarAction(
              icon: Icons.add_rounded,
              tooltip: 'Add to ${_labels[_index].toLowerCase()}',
              onPressed: () => openSearch(context, type: type),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          PillSegments(labels: _labels, selected: _index, onChanged: _select),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pages,
              onPageChanged: (i) {
                if (!_animating) setState(() => _index = i);
              },
              children: const [
                MediaListScreen(type: MediaType.movie),
                MediaListScreen(type: MediaType.series),
                MediaListScreen(type: MediaType.book),
                ListsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}