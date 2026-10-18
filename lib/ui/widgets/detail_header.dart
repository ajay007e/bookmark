import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import 'poster_card.dart';

/// Collapsing poster header used at the top of every detail page.
class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;

    return SliverAppBar(
      pinned: true,
      expandedHeight: MediaQuery.sizeOf(context).height * 0.6,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage.fromItem(item, hd: true),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, background],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}