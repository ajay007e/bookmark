import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/app_database.dart';

IconData _iconFor(MediaType type) => switch (type) {
  MediaType.book => Icons.menu_book,
  MediaType.movie => Icons.movie,
  MediaType.series => Icons.tv,
};

/// Poster or cover image, with a simple placeholder when there is no image.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.type,
    required this.title,
    this.url,
  });

  PosterImage.fromItem(MediaItem item, {Key? key})
      : this(key: key, type: item.type, title: item.title, url: item.posterUrl);

  final MediaType type;
  final String title;
  final String? url;

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

    final imageUrl = url;
    if (imageUrl == null) return placeholder;
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}

class PosterCard extends StatelessWidget {
  const PosterCard({super.key, required this.item, this.width});

  final MediaItem item;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = Column(
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
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}