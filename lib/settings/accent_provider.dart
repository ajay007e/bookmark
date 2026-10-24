import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'accent';

class AccentOption {
  const AccentOption(this.id, this.name, this.color);

  final String id; // saved on the phone
  final String name; // shown in the label and tooltip
  final Color color;
}

/// The colours the user can pick from. The first one is the default.
/// Keep the ids unchanged once released, because they are saved on the phone.
const accentOptions = <AccentOption>[
  AccentOption('teal', 'Teal', Colors.teal),
  AccentOption('blue', 'Blue', Colors.blue),
  AccentOption('indigo', 'Indigo', Colors.indigo),
  AccentOption('purple', 'Purple', Colors.deepPurple),
  AccentOption('pink', 'Pink', Colors.pink),
  AccentOption('red', 'Red', Colors.red),
  AccentOption('orange', 'Orange', Colors.deepOrange),
  AccentOption('green', 'Green', Colors.green),
  AccentOption('sky', 'Sky', Colors.lightBlue),
  AccentOption('cyan', 'Cyan', Colors.cyan),
  AccentOption('violet', 'Violet', Colors.purple),
  AccentOption('rose', 'Rose', Colors.pinkAccent),
  AccentOption('amber', 'Amber', Colors.amber),
  AccentOption('lime', 'Lime', Colors.lime),
  AccentOption('brown', 'Brown', Colors.brown),
  AccentOption('slate', 'Slate', Colors.blueGrey),
];

/// The accent colour the user picked. Saved on the phone.
final accentProvider =
NotifierProvider<AccentNotifier, AccentOption>(AccentNotifier.new);

class AccentNotifier extends Notifier<AccentOption> {
  final _prefs = SharedPreferencesAsync();

  @override
  AccentOption build() {
    _load(); // read the saved choice in the background
    return accentOptions.first;
  }

  Future<void> _load() async {
    final saved = await _prefs.getString(_key);
    state = accentOptions.where((a) => a.id == saved).firstOrNull ??
        accentOptions.first;
  }

  Future<void> set(AccentOption option) async {
    state = option; // the whole app re-colours immediately
    await _prefs.setString(_key, option.id);
  }
}