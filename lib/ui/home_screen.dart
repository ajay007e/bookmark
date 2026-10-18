import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'search_screen.dart';
import 'widgets/empty_state.dart';
import 'widgets/poster_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(itemCountProvider);
    final hero = ref.watch(heroProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
        actions: [
          IconButton(
            tooltip: 'Search and add',
            icon: const Icon(Icons.search),
            onPressed: () => openSearch(context),
          ),
        ],
      ),
      body: count.maybeWhen(
        data: (n) => n == 0
            ? EmptyState(
          title: 'Your Bookmark is empty',
          message:
          'Search for a movie, series or book and add it to start tracking what you watch and read.',
          actionLabel: 'Search and add',
          onAction: () => openSearch(context),
        )
            : ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            hero.when(
              data: (items) => items.isEmpty
                  ? const _EmptyHero()
                  : _HeroCarousel(items: items),
              loading: () => const SizedBox(
                height: 230,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Something went wrong: $e'),
              ),
            ),
            _PosterRow(title: 'Recently watched', items: ref.watch(recentWatchedProvider)),
            _PosterRow(title: 'Recently read', items: ref.watch(recentReadProvider)),
            _PosterRow(title: 'Movie wish list', items: ref.watch(wishlistProvider(MediaType.movie))),
            _PosterRow(title: 'Series wish list', items: ref.watch(wishlistProvider(MediaType.series))),
            _PosterRow(title: 'Book wish list', items: ref.watch(wishlistProvider(MediaType.book))),
          ],
        ),
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 140,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        'Nothing in progress right now.\nStart something from your wish list.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.items});

  final List<MediaItem> items;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        itemBuilder: (_, i) => _HeroCard(item: widget.items[i]),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.item});

  final MediaItem item;

  String get _subtitle {
    if (item.type == MediaType.book) {
      final pages = item.pageCount;
      return pages == null
          ? 'Reading'
          : 'Reading · page ${item.currentPage} of $pages';
    }
    return item.status == Status.done ? 'New episode available' : 'Watching';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pages = item.pageCount;
    final showProgress =
        item.type == MediaType.book && pages != null && pages > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage.fromItem(item),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _subtitle,
                    style: text.labelLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showProgress) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (item.currentPage / pages).clamp(0.0, 1.0),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.title, required this.items});

  final String title;
  final AsyncValue<List<MediaItem>> items;

  @override
  Widget build(BuildContext context) {
    return items.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(
              height: 205,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => PosterCard(item: list[i], width: 110),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}