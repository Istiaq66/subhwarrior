import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's theme preference as a 3-way [ThemeMode]
/// (system / light / dark), defaulting to `system`, and persists it.
class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'themeMode';
  static const _legacyKey = 'isDarkMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
    } else if (prefs.containsKey(_legacyKey)) {
      // Migrate the old boolean dark-mode flag to the new 3-way mode.
      _themeMode = (prefs.getBool(_legacyKey) ?? false)
          ? ThemeMode.dark
          : ThemeMode.light;
      await prefs.setString(_prefsKey, _themeMode.name);
      await prefs.remove(_legacyKey);
    }
    notifyListeners();
  }
}
