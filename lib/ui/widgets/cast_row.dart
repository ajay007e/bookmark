import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/detail_info.dart';

/// Horizontal list of round cast photos with name and character.
class CastRow extends StatelessWidget {
  const CastRow({super.key, required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = cast[i];
          final photo = c.photoUrl;
          final role = c.character;
          return SizedBox(
            width: 84,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: scheme.surfaceContainerHighest,
                  backgroundImage:
                  photo == null ? null : CachedNetworkImageProvider(photo),
                  child: photo == null
                      ? Icon(Icons.person, color: scheme.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: text.labelMedium,
                ),
                if (role != null && role.isNotEmpty)
                  Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}