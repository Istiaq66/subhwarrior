import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cached_prayer_times.dart';
import '../domain/prayer_settings.dart';
import '../domain/prayer_times.dart';
import 'location_data_source.dart';
import 'prayer_times_local_data_source.dart';
import 'prayer_times_remote_data_source.dart';

/// Repository contract for prayer times. The controller depends on this, not
/// on http/SharedPreferences/Geolocator directly (IMPROVEMENT_PLAN B3).
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
  final PrayerTimesRemoteDataSource _remote;
  final PrayerTimesLocalDataSource _local;
  final LocationDataSource _location;

  PrayerTimesRepositoryImpl(this._remote, this._local, this._location);

  factory PrayerTimesRepositoryImpl.fromPrefs(SharedPreferences prefs) =>
      PrayerTimesRepositoryImpl(
        PrayerTimesRemoteDataSource(),
        PrayerTimesLocalDataSource(prefs),
        LocationDataSource(),
      );

  @override
  Future<PrayerTimes> fetchByCoordinates(
    DateTime date,
    double latitude,
    double longitude,
    PrayerSettings settings,
  ) =>
      _remote.fetchByCoordinates(
        date: date,
        latitude: latitude,
        longitude: longitude,
        method: settings.calculationMethod,
        school: settings.school,
      );

  @override
  Future<PrayerTimes> fetchByCity(
    DateTime date,
    String city,
    String country,
    PrayerSettings settings,
  ) =>
      _remote.fetchByCity(
        date: date,
        city: city,
        country: country,
        method: settings.calculationMethod,
        school: settings.school,
      );

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
