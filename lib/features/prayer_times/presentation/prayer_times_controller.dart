import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/prayer_times_repository.dart';
import '../domain/prayer_settings.dart';
import '../domain/prayer_times.dart';

/// Thin controller over [PrayerTimesRepository]. Holds no http, Geolocator or
/// SharedPreferences instances directly (IMPROVEMENT_PLAN B3) — all I/O goes
/// through the repository. Time-window math and formatting live here.
class PrayerTimeProvider extends ChangeNotifier {
  final PrayerTimesRepository _repository;

  PrayerTimes? _todayPrayerTimes;
  PrayerTimes? _tomorrowPrayerTimes;
  bool _isLoading = false;
  String _error = '';
  PrayerSettings _settings;

  PrayerTimeProvider(this._repository) : _settings = _repository.loadSettings();

  /// Convenience constructor used by app wiring.
  factory PrayerTimeProvider.fromPrefs(SharedPreferences prefs) =>
      PrayerTimeProvider(PrayerTimesRepositoryImpl.fromPrefs(prefs));

  PrayerTimes? get todayPrayerTimes => _todayPrayerTimes;
  PrayerTimes? get tomorrowPrayerTimes => _tomorrowPrayerTimes;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get calculationMethod => _settings.calculationMethod;
  bool get useHanafiMethod => _settings.useHanafiMethod;

  DateTime? get todayFajrTime {
    if (_todayPrayerTimes == null) return null;
    return _onDay(DateTime.now(), _todayPrayerTimes!.fajr);
  }

  DateTime? get tomorrowFajrTime {
    if (_tomorrowPrayerTimes == null) return null;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _onDay(tomorrow, _tomorrowPrayerTimes!.fajr);
  }

  /// Whether the current time is within today's Fajr window (Fajr → sunrise).
  bool isWithinFajrTime() {
    if (_todayPrayerTimes == null) return false;

    final now = DateTime.now();
    final fajrTime = todayFajrTime;
    final sunriseTime = _onDay(now, _todayPrayerTimes!.sunrise);

    if (fajrTime == null || sunriseTime == null) return false;
    return now.isAfter(fajrTime) && now.isBefore(sunriseTime);
  }

  Future<void> fetchPrayerTimes(double latitude, double longitude) async {
    await _runFetch(() async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      _todayPrayerTimes = await _repository.fetchByCoordinates(
          today, latitude, longitude, _settings);
      _tomorrowPrayerTimes = await _repository.fetchByCoordinates(
          tomorrow, latitude, longitude, _settings);
    });
  }

  Future<void> fetchPrayerTimesByCity(String city, String country) async {
    await _runFetch(() async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      _todayPrayerTimes =
          await _repository.fetchByCity(today, city, country, _settings);
      _tomorrowPrayerTimes =
          await _repository.fetchByCity(tomorrow, city, country, _settings);
    });
  }

  Future<void> fetchPrayerTimesForCurrentLocation() async {
    try {
      final coords = await _repository.currentCoordinates();
      await fetchPrayerTimes(coords.latitude, coords.longitude);
    } catch (e) {
      _error = 'Failed to get location: $e';
      notifyListeners();
    }
  }

  void updateCalculationMethod(int method) {
    _settings = _settings.copyWith(calculationMethod: method);
    _repository.saveSettings(_settings);
    notifyListeners();
  }

  void updateJuristicMethod(bool useHanafi) {
    _settings = _settings.copyWith(useHanafiMethod: useHanafi);
    _repository.saveSettings(_settings);
    notifyListeners();
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('hh:mm a').format(time);
  }

  String getTimeUntilFajr() {
    DateTime? nextFajr;
    final now = DateTime.now();

    if (todayFajrTime != null && now.isBefore(todayFajrTime!)) {
      nextFajr = todayFajrTime;
    } else if (tomorrowFajrTime != null) {
      nextFajr = tomorrowFajrTime;
    }

    if (nextFajr == null) return 'Unknown';

    final difference = nextFajr.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Shared fetch wrapper: toggles loading/error and defers notifications to
  /// avoid notifying during a build frame.
  Future<void> _runFetch(Future<void> Function() body) async {
    _isLoading = true;
    _error = '';
    _notifyDeferred();

    try {
      await body();
    } catch (e) {
      _error = 'Failed to fetch prayer times: $e';
    } finally {
      _isLoading = false;
      _notifyDeferred();
    }
  }

  void _notifyDeferred() {
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  /// Builds a [DateTime] on [day]'s calendar date from an "HH:mm" string.
  DateTime? _onDay(DateTime day, String timeStr) {
    try {
      final parts = timeStr.split(':');
      return DateTime(day.year, day.month, day.day, int.parse(parts[0]),
          int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }
}
