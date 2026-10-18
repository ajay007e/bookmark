import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadNote extends StatelessWidget {
  const LoadNote({super.key, required this.state, required this.what});

  final AsyncValue<Object?> state;
  final String what;

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: (_) => const SizedBox.shrink(),
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Loading $what...'),
          ],
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          "Couldn't load $what. Check your connection.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}