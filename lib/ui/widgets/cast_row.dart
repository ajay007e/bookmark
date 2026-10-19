import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/detail_info.dart';

/// Horizontal list of round cast photos with name and character.
/// As tall as its content, so there is no empty space under it.
class CastRow extends StatelessWidget {
  const CastRow({super.key, required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cast.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            _CastTile(member: cast[i]),
          ],
        ],
      ),
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final photo = member.photoUrl;
    final role = member.character;

    return SizedBox(
      width: 84,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.surfaceContainerHighest,
            backgroundImage: photo == null ? null : CachedNetworkImageProvider(photo),
            child: photo == null
                ? Icon(Icons.person, color: scheme.onSurfaceVariant)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
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
  }
}