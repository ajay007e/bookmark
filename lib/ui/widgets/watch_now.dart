import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/detail_info.dart';

/// "Watch now": where it can be streamed, rented or bought in Australia.
/// Pass null while the details are still loading.
class WatchNowSection extends StatelessWidget {
  const WatchNowSection({super.key, required this.options});

  final WatchOptions? options;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(options?.link ?? '');
    var opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open the link.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = options;
    if (o == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Watch now', style: text.titleMedium),
          const SizedBox(height: 8),
          if (o.isEmpty)
            Text(
              'Not on any streaming service in Australia right now.',
              style: text.bodyMedium,
            )
          else ...[
            _group(context, 'Stream', o.stream),
            _group(context, 'Free', o.free),
            _group(context, 'Rent', o.rent),
            _group(context, 'Buy', o.buy),
            const SizedBox(height: 4),
            Text(
              'Streaming data by JustWatch, via TMDB.',
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String label, List<WatchProvider> list) {
    if (list.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in list)
                  Tooltip(
                    message: p.name,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _open(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: p.logoUrl == null
                              ? ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: Center(
                              child: Text(
                                p.name.isEmpty ? '?' : p.name[0],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          )
                              : CachedNetworkImage(
                            imageUrl: p.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                ColoredBox(color: scheme.surfaceContainerHighest),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}