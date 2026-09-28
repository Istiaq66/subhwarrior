import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/providers/locale_provider.dart';

/// Resolves the user's chosen locale without a [BuildContext].
///
/// Notifications, the Fajr call and anything else running in a background
/// isolate have no widget tree to read `Localizations` from, but they still
/// show text to the user — so they read the same stored preference the app
/// does, falling back to the platform locale and then to English.
Future<AppLocalizations> loadStoredL10n() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(LocaleProvider.prefsKey);
  var locale =
      stored != null ? Locale(stored) : PlatformDispatcher.instance.locale;
  if (!AppLocalizations.delegate.isSupported(locale)) {
    locale = const Locale('en');
  }
  return lookupAppLocalizations(locale);
}
