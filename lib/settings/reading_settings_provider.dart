import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reading_settings.dart';

class ReadingSettingsNotifier extends AsyncNotifier<ReadingSettings> {
  @override
  Future<ReadingSettings> build() => loadReadingSettings();

  Future<void> save(ReadingSettings settings) async {
    await saveReadingSettings(settings);
    state = AsyncData(settings);
  }
}

final readingSettingsProvider =
AsyncNotifierProvider<ReadingSettingsNotifier, ReadingSettings>(
  ReadingSettingsNotifier.new,
);