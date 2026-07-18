import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's language preference as a nullable [Locale]
/// (null = follow system), and persists it.
class LocaleProvider extends ChangeNotifier {
  /// SharedPreferences key holding the chosen language code. Public so
  /// context-free code (e.g. NotificationService) can resolve the same choice.
  static const prefsKey = 'appLocale';

  Locale? _locale;

  /// The chosen locale, or null to follow the system locale.
  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(prefsKey);
    } else {
      await prefs.setString(prefsKey, locale.languageCode);
    }
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(prefsKey);
    if (stored != null) {
      _locale = Locale(stored);
      notifyListeners();
    }
  }
}
