import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../reading/reading_session_provider.dart';
import '../session_actions.dart';

class ElapsedText extends StatefulWidget {
  const ElapsedText({
    super.key,
    required this.since,
    this.style,
    this.compact = false,
  });

  final DateTime since;
  final TextStyle? style;
  final bool compact;

  @override
  State<ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends State<ElapsedText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (widget.compact && h > 0) return '${h}h$m';
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.since);
    return Text(
      _format(elapsed.isNegative ? Duration.zero : elapsed),
      style: widget.style,
    );
  }
}

class HeroSessionButton extends ConsumerWidget {
  const HeroSessionButton({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(readingSessionProvider).session;
    final running = s != null && s.itemId == item.id;
    final style = TextButton.styleFrom(foregroundColor: Colors.white);

    if (running) {
      return TextButton.icon(
        style: style,
        icon: const Icon(Icons.stop_circle_outlined),
        label: ElapsedText(since: s.startedAt),
        onPressed: () => stopSession(context, ref, item),
      );
    }
    return TextButton.icon(
      style: style,
      icon: const Icon(Icons.timer_outlined),
      label: const Text('Start session'),
      onPressed: () => startSession(context, ref, item),
    );
  }
}