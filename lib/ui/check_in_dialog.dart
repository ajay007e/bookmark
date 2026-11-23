import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showCheckInDialog(
    BuildContext context,
    DateTime deadline,
    Duration total,
    ) async {
  final answer = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: _CheckIn(deadline: deadline, total: total),
    ),
  );
  return answer ?? false;
}

class _CheckIn extends StatefulWidget {
  const _CheckIn({required this.deadline, required this.total});

  final DateTime deadline;
  final Duration total;

  @override
  State<_CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<_CheckIn> {
  Timer? _timer;
  late Duration _left = widget.deadline.difference(DateTime.now());

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = widget.deadline.difference(DateTime.now());
      if (!mounted) return;
      if (left <= Duration.zero) {
        _timer?.cancel();
        Navigator.of(context).pop(false);
        return;
      }
      HapticFeedback.heavyImpact();
      setState(() => _left = left);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final seconds = _left.inSeconds < 0 ? 0 : _left.inSeconds;
    final clock =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    final fraction = widget.total.inSeconds == 0
        ? 0.0
        : (seconds / widget.total.inSeconds).clamp(0.0, 1.0);

    return AlertDialog(
      backgroundColor: scheme.errorContainer,
      icon: Icon(Icons.alarm, size: 40, color: scheme.error),
      title: const Text('Still reading?', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: fraction,
                    strokeWidth: 8,
                    color: scheme.error,
                    backgroundColor:
                    scheme.onErrorContainer.withValues(alpha: 0.15),
                  ),
                ),
                Text(
                  clock,
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Answer before the countdown ends or the session stops.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onErrorContainer),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Stop session'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes, still reading'),
        ),
      ],
    );
  }
}