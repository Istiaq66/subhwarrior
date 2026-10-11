import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cached_prayer_times.dart';
import '../domain/prayer_settings.dart';
import 'location_data_source.dart';

/// Reads/writes prayer calculation preferences, the last-resolved prayer
/// times, and the last geocoded city to [SharedPreferences].
class PrayerTimesLocalDataSource {
  final SharedPreferences prefs;

  PrayerTimesLocalDataSource(this.prefs);

  static const _kMethod = 'prayer_calculation_method';
  static const _kHanafi = 'prayer_hanafi_method';
  static const _k24Hour = 'clock_24_hour_format';
  static const _kDefaultsCountry = 'prayer_defaults_country';
  static const _kCache = 'prayer_times_cache';
  static const _kCityCoordinates = 'prayer_city_coordinates';

  PrayerSettings load() => PrayerSettings(
        calculationMethod:
            prefs.getInt(_kMethod) ?? PrayerSettings.defaultCalculationMethod,
        useHanafiMethod: prefs.getBool(_kHanafi) ?? false,
        use24HourFormat: prefs.getBool(_k24Hour) ?? false,
        defaultsCountryCode: prefs.getString(_kDefaultsCountry),
      );

  Future<void> save(PrayerSettings settings) async {
    await prefs.setInt(_kMethod, settings.calculationMethod);
    await prefs.setBool(_kHanafi, settings.useHanafiMethod);
    await prefs.setBool(_k24Hour, settings.use24HourFormat);
    final country = settings.defaultsCountryCode;
    if (country == null) {
      await prefs.remove(_kDefaultsCountry);
    } else {
      await prefs.setString(_kDefaultsCountry, country);
    }
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

  /// Coordinates last geocoded for [city], [country], or null when nothing is
  /// stored for that place. One entry only: a profile has one city at a time,
  /// and a different city simply misses.
  Coordinates? loadCityCoordinates(String city, String country) {
    final raw = prefs.getString(_kCityCoordinates);
    if (raw == null) return null;

    try {
      final decoded = json.decode(raw);
      if (decoded is! Map || decoded['key'] != _cityKey(city, country)) {
        return null;
      }
      return (
        latitude: (decoded['latitude'] as num).toDouble(),
        longitude: (decoded['longitude'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('PrayerTimesLocalDataSource: unreadable city entry: $e');
      return null;
    }
  }

  Future<void> saveCityCoordinates(
    String city,
    String country,
    Coordinates coordinates,
  ) =>
      prefs.setString(
        _kCityCoordinates,
        json.encode({
          'key': _cityKey(city, country),
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
        }),
      );

  static String _cityKey(String city, String country) =>
      '${city.trim().toLowerCase()}|${country.trim().toLowerCase()}';
}
