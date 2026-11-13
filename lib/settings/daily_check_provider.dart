import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../background/background_worker.dart';

/// Holds the You > New episodes switch (true = daily check on).
class DailyCheckNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => isDailyCheckEnabled();

  Future<void> set(bool enabled) async {
    final before = state.asData?.value ?? true;
    state = AsyncData(enabled); // the switch moves at once
    try {
      await setDailyCheck(enabled);
    } catch (_) {
      state = AsyncData(before); // scheduling failed: put the switch back
    }
  }
}

final dailyCheckProvider =
AsyncNotifierProvider<DailyCheckNotifier, bool>(DailyCheckNotifier.new);