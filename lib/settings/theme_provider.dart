import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'themeMode';

/// The theme the user picked: system, light or dark. Saved on the phone.
final themeModeProvider =
NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  final _prefs = SharedPreferencesAsync();

  @override
  ThemeMode build() {
    _load(); // read the saved choice in the background
    return ThemeMode.system; // used until the saved value arrives
  }

  Future<void> _load() async {
    final saved = await _prefs.getString(_key);
    state = ThemeMode.values.where((m) => m.name == saved).firstOrNull ??
        ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode; // the whole app switches immediately
    await _prefs.setString(_key, mode.name);
  }
}