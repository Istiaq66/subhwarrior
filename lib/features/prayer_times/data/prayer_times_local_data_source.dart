import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cached_prayer_times.dart';
import '../domain/prayer_settings.dart';

/// Reads/writes prayer calculation preferences and the last-fetched prayer
/// times to [SharedPreferences].
class PrayerTimesLocalDataSource {
  final SharedPreferences prefs;

  PrayerTimesLocalDataSource(this.prefs);

  static const _kMethod = 'prayer_calculation_method';
  static const _kHanafi = 'prayer_hanafi_method';
  static const _k24Hour = 'clock_24_hour_format';
  static const _kCache = 'prayer_times_cache';

  PrayerSettings load() => PrayerSettings(
        calculationMethod:
            prefs.getInt(_kMethod) ?? PrayerSettings.defaultCalculationMethod,
        useHanafiMethod: prefs.getBool(_kHanafi) ?? false,
        use24HourFormat: prefs.getBool(_k24Hour) ?? false,
      );

  Future<void> save(PrayerSettings settings) async {
    await prefs.setInt(_kMethod, settings.calculationMethod);
    await prefs.setBool(_kHanafi, settings.useHanafiMethod);
    await prefs.setBool(_k24Hour, settings.use24HourFormat);
  }

  /// The cached prayer times, or null when nothing is stored or the stored
  /// value can't be read. Callers must still check
  /// [CachedPrayerTimes.isValidFor] — this only decodes.
  CachedPrayerTimes? loadCache() {
    final raw = prefs.getString(_kCache);
    if (raw == null) return null;

    try {
      final decoded = json.decode(raw);
      if (decoded is! Map) return null;
      return CachedPrayerTimes.fromCacheMap(Map<String, dynamic>.from(decoded));
    } catch (e) {
      // A corrupt or format-changed entry must not break startup: the app
      // simply behaves as though it had never cached anything.
      debugPrint('PrayerTimesLocalDataSource: unreadable cache dropped: $e');
      return null;
    }
  }

  Future<void> saveCache(CachedPrayerTimes cache) =>
      prefs.setString(_kCache, json.encode(cache.toCacheMap()));

  Future<void> clearCache() => prefs.remove(_kCache);
}
