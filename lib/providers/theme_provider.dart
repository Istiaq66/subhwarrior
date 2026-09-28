import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's theme preference as a 3-way [ThemeMode]
/// (system / light / dark), defaulting to `system`, and persists it.
///
/// The stored value is read synchronously from an already-loaded
/// [SharedPreferences]: resolving it asynchronously meant the first frame —
/// the splash screen — was always painted in the default theme, and a
/// dark-mode user watched it flip one frame later.
class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'themeMode';
  static const _legacyKey = 'isDarkMode';

  ThemeProvider(this._prefs) {
    _themeMode = _readStoredMode();
  }

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_prefsKey, mode.name);
  }

  ThemeMode _readStoredMode() {
    final stored = _prefs.getString(_prefsKey);
    if (stored != null) {
      return ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
    }

    if (!_prefs.containsKey(_legacyKey)) return ThemeMode.system;

    // Migrate the old boolean dark-mode flag to the new 3-way mode. The reads
    // are synchronous; only the rewrite has to wait, and nothing reads the
    // keys again this launch.
    final migrated = (_prefs.getBool(_legacyKey) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
    _prefs.setString(_prefsKey, migrated.name);
    _prefs.remove(_legacyKey);
    return migrated;
  }
}
