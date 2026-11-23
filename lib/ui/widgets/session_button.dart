import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/reading_queries.dart';
import '../../reading/reading_session_provider.dart';
import '../reading_actions.dart';
import '../session_actions.dart';
import 'session_card.dart';

class SessionButton extends ConsumerWidget {
  const SessionButton({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = ref.watch(readingSessionProvider).session;
    final running = s != null && s.itemId == item.id;

    final fraction = item.progressMax == 0
        ? 0.0
        : (item.currentPage / item.progressMax).clamp(0.0, 1.0);

    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: running ? scheme.onPrimary : scheme.onSurface,
    );

    return Semantics(
      button: true,
      label: running ? 'Stop reading session' : 'Start reading session',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => running
            ? stopSession(context, ref, item)
            : startSession(context, ref, item),
        onLongPress:
        running ? null : () => updateProgressFlow(context, ref, item),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (running)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                    ),
                  ),
                ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircularProgressIndicator(
                    value: fraction,
                    strokeWidth: 3,
                    backgroundColor: running
                        ? scheme.onPrimary.withValues(alpha: 0.3)
                        : scheme.outlineVariant,
                    color: running ? scheme.onPrimary : scheme.primary,
                  ),
                ),
              ),
              if (running)
                ElapsedText(since: s.startedAt, compact: true, style: labelStyle)
              else
                Text('${item.percentDone}%', style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}