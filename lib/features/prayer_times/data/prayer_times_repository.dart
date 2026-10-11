import 'package:shared_preferences/shared_preferences.dart';

import '../domain/prayer_settings.dart';
import '../domain/prayer_times.dart';
import 'location_data_source.dart';
import 'prayer_times_calculator.dart';
import 'prayer_times_local_data_source.dart';

/// Repository contract for prayer times. The controller depends on this, not
/// on SharedPreferences/Geolocator directly (IMPROVEMENT_PLAN B3).
///
/// [fetchByCoordinates] calculates on the device; nothing here needs a network.
abstract class PrayerTimesRepository {
  Future<PrayerTimes> fetchByCoordinates(
    DateTime date,
    double latitude,
    double longitude,
    PrayerSettings settings,
  );

  /// Current device coordinates. May throw a [String] message on failure.
  Future<Coordinates> currentCoordinates();

  PrayerSettings loadSettings();
  Future<void> saveSettings(PrayerSettings settings);
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

  @override
  Future<Coordinates> currentCoordinates() => _location.currentPosition();

  @override
  PrayerSettings loadSettings() => _local.load();

  @override
  Future<void> saveSettings(PrayerSettings settings) => _local.save(settings);
}
