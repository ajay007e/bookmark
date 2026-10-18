import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';

IconData _iconFor(MediaType type) => switch (type) {
  MediaType.book => Icons.menu_book,
  MediaType.movie => Icons.movie,
  MediaType.series => Icons.tv,
};

/// The database stores medium images. Big views ask for a larger version.
String _hdUrl(String url) => url
    .replaceFirst('/t/p/w342/', '/t/p/w780/') // TMDB posters
    .replaceFirst('-M.jpg', '-L.jpg'); // Open Library covers

/// Poster or cover image, with a simple placeholder when there is no image.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.type,
    required this.title,
    this.url,
    this.hd = false,
  });

  PosterImage.fromItem(MediaItem item, {Key? key, bool hd = false})
      : this(
    key: key,
    type: item.type,
    title: item.title,
    url: item.posterUrl,
    hd: hd,
  );

  final MediaType type;
  final String title;
  final String? url;

  /// Load a larger, sharper image (for hero cards and detail pages).
  final bool hd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final placeholder = LayoutBuilder(
      builder: (context, constraints) {
        final small = constraints.maxWidth < 80;
        return Container(
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: small
              ? Icon(_iconFor(type), color: scheme.onSurfaceVariant)
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(type), color: scheme.onSurfaceVariant),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );

    final original = url;
    if (original == null) return placeholder;

    // While the HD image loads (or if it fails), show the normal-size image,
    // which is usually already cached from the list screens.
    final fallback = hd
        ? CachedNetworkImage(
      imageUrl: original,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => placeholder,
    )
        : placeholder;

    return CachedNetworkImage(
      imageUrl: hd ? _hdUrl(original) : original,
      fit: BoxFit.cover,
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}

class PosterCard extends StatelessWidget {
  const PosterCard({super.key, required this.item, this.width});

  final MediaItem item;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/item/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PosterImage.fromItem(item),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}