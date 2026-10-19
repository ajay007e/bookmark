import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'search_screen.dart';
import 'series_actions.dart';
import 'widgets/empty_state.dart';
import 'widgets/poster_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(itemCountProvider);
    final hero = ref.watch(heroProvider);
    final heroHeight = MediaQuery.sizeOf(context).height * 0.6;

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
                  : _HeroCarousel(items: items, height: heroHeight),
              loading: () => SizedBox(
                height: heroHeight,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Something went wrong: $e'),
              ),
            ),
            _PosterRow(
              title: 'Recently watched',
              items: ref.watch(recentWatchedProvider),
            ),
            _PosterRow(
              title: 'Recently read',
              items: ref.watch(recentReadProvider),
            ),
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
  const _HeroCarousel({required this.items, required this.height});

  final List<MediaItem> items;
  final double height;

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
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        itemBuilder: (_, i) => _HeroCard(item: widget.items[i]),
      ),
    );
  }
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final db = ref.read(databaseProvider);
    final isSeries = item.type == MediaType.series;
    final isBook = item.type == MediaType.book;

    final eps = isSeries
        ? ref
        .watch(episodesProvider(item.id))
        .maybeWhen<List<Episode>>(data: (l) => l, orElse: () => const <Episode>[])
        : const <Episode>[];
    final now = DateTime.now();
    final next = isSeries ? nextEpisode(eps, now) : null;

    var subtitle = switch (item.type) {
      MediaType.book => 'Reading',
      MediaType.movie => 'Watching',
      MediaType.series => 'Up next',
    };
    if (isSeries) {
      final hasNew = item.status == Status.done ||
          eps.any((e) =>
          !e.watched && isAired(e, now) && e.airDate!.isAfter(item.lastActivityAt));
      if (hasNew) subtitle = 'New episode available';
    }

    // The same round tick for series, books and movies.
    Widget tick(String tooltip, VoidCallback onPressed) => IconButton.filled(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      icon: const Icon(Icons.check),
      onPressed: onPressed,
    );

    final title = Text(
      item.title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: text.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    final Widget titleBlock;
    if (isSeries) {
      // Title, then "S2 E5 · Episode title" with the tick at the end.
      final n = next;
      titleBlock = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          if (n != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'S${n.seasonNumber} E${n.episodeNumber} · ${n.title ?? 'Episode ${n.episodeNumber}'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                tick(
                  'Mark as watched',
                      () => tickEpisodes(
                    context,
                    ref,
                    seriesId: item.id,
                    all: eps,
                    targets: [n],
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    } else {
      // Books and movies: the tick sits at the end of the title.
      titleBlock = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: title),
          const SizedBox(width: 12),
          tick(
            isBook ? 'Mark as read' : 'Mark as watched',
                () => db.markDone(item, counted: true),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => context.push('/item/${item.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PosterImage.fromItem(item, hd: true),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: text.titleSmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    titleBlock,
                  ],
                ),
              ),
            ],
          ),
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