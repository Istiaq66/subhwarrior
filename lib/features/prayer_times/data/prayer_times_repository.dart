import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cached_prayer_times.dart';
import '../domain/prayer_settings.dart';
import '../domain/prayer_times.dart';
import 'location_data_source.dart';
import 'prayer_times_calculator.dart';
import 'prayer_times_local_data_source.dart';

/// Repository contract for prayer times. The controller depends on this, not
/// on SharedPreferences/Geolocator directly (IMPROVEMENT_PLAN B3).
///
/// The `fetch*` methods calculate on the device; only a city that has never
/// been geocoded touches the network.
abstract class PrayerTimesRepository {
  Future<PrayerTimes> fetchByCoordinates(
    DateTime date,
    double latitude,
    double longitude,
    PrayerSettings settings,
  );

  Future<PrayerTimes> fetchByCity(
    DateTime date,
    String city,
    String country,
    PrayerSettings settings,
  );

  /// Current device coordinates. May throw a [String] message on failure.
  Future<Coordinates> currentCoordinates();

  PrayerSettings loadSettings();
  Future<void> saveSettings(PrayerSettings settings);

  /// Last successfully fetched times, or null when none are stored. Read
  /// synchronously so the controller can hydrate in its constructor, the same
  /// way [loadSettings] does.
  CachedPrayerTimes? loadCachedTimes();
  Future<void> saveCachedTimes(CachedPrayerTimes cache);
}

class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final PrayerTimesCalculator _calculator;
  final PrayerTimesLocalDataSource _local;
  final LocationDataSource _location;

  PrayerTimesRepositoryImpl(this._calculator, this._local, this._location);

  factory PrayerTimesRepositoryImpl.fromPrefs(SharedPreferences prefs) =>
      PrayerTimesRepositoryImpl(
        const PrayerTimesCalculator(),
        PrayerTimesLocalDataSource(prefs),
        LocationDataSource(),
      );

  @override
  Future<PrayerTimes> fetchByCoordinates(
    DateTime date,
    double latitude,
    double longitude,
    PrayerSettings settings,
  ) async =>
      _calculator.calculate(
        date: date,
        latitude: latitude,
        longitude: longitude,
        method: settings.calculationMethod,
        school: settings.school,
      );

  /// Geocodes the city once — the only step that can need a network — and
  /// remembers the answer, so every later day calculates offline.
  @override
  Future<PrayerTimes> fetchByCity(
    DateTime date,
    String city,
    String country,
    PrayerSettings settings,
  ) async {
    var coordinates = _local.loadCityCoordinates(city, country);
    if (coordinates == null) {
      coordinates = await _location.cityCoordinates(city, country);
      await _local.saveCityCoordinates(city, country, coordinates);
    }
    return fetchByCoordinates(
        date, coordinates.latitude, coordinates.longitude, settings);
  }

  @override
  Future<Coordinates> currentCoordinates() => _location.currentPosition();

  @override
  PrayerSettings loadSettings() => _local.load();

  @override
  Future<void> saveSettings(PrayerSettings settings) => _local.save(settings);

  @override
  CachedPrayerTimes? loadCachedTimes() => _local.loadCache();

  @override
  Future<void> saveCachedTimes(CachedPrayerTimes cache) =>
      _local.saveCache(cache);
}
