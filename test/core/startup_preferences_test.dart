import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/providers/locale_provider.dart';
import 'package:subh_warrior/providers/theme_provider.dart';

/// Regression: both providers used to `await SharedPreferences.getInstance()`
/// in their constructor, so the stored choice landed a frame *after* the
/// splash was painted — the first frame was always system theme and system
/// locale, then flipped. They now read the instance boot already loaded.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('ThemeProvider', () {
    test('reads the stored mode before the first frame', () async {
      final prefs = await prefsWith({'themeMode': 'dark'});

      expect(ThemeProvider(prefs).themeMode, ThemeMode.dark);
    });

    test('falls back to system when nothing is stored', () async {
      final prefs = await prefsWith({});

      expect(ThemeProvider(prefs).themeMode, ThemeMode.system);
    });

    test('falls back to system when the stored mode is unknown', () async {
      final prefs = await prefsWith({'themeMode': 'sepia'});

      expect(ThemeProvider(prefs).themeMode, ThemeMode.system);
    });

    test('migrates the legacy dark-mode flag on the same frame', () async {
      final prefs = await prefsWith({'isDarkMode': true});

      expect(ThemeProvider(prefs).themeMode, ThemeMode.dark);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('themeMode'), 'dark');
      expect(prefs.containsKey('isDarkMode'), isFalse);
    });

    test('persists a change through the instance it was given', () async {
      final prefs = await prefsWith({});
      final provider = ThemeProvider(prefs);

      await provider.setThemeMode(ThemeMode.light);

      expect(provider.themeMode, ThemeMode.light);
      expect(prefs.getString('themeMode'), 'light');
    });
  });

  group('LocaleProvider', () {
    test('reads the stored locale before the first frame', () async {
      final prefs = await prefsWith({LocaleProvider.prefsKey: 'ar'});

      expect(LocaleProvider(prefs).locale, const Locale('ar'));
    });

    test('follows the system locale when nothing is stored', () async {
      final prefs = await prefsWith({});

      expect(LocaleProvider(prefs).locale, isNull);
    });

    test('clearing the choice removes the key', () async {
      final prefs = await prefsWith({LocaleProvider.prefsKey: 'bn'});
      final provider = LocaleProvider(prefs);

      await provider.setLocale(null);

      expect(provider.locale, isNull);
      expect(prefs.containsKey(LocaleProvider.prefsKey), isFalse);
    });
  });
}
