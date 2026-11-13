import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true while an unsaved series is being saved (and its first mark applied).
/// The series page shows a full-page spinner meanwhile, so the switch from
/// "not in the library" to "saved" never shows half-loaded content.
class DraftSavingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final draftSavingProvider =
NotifierProvider<DraftSavingNotifier, bool>(DraftSavingNotifier.new);