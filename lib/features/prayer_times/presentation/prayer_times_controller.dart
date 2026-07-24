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
  bool get use24HourFormat => _settings.use24HourFormat;

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

  void updateTimeFormat(bool use24Hour) {
    _settings = _settings.copyWith(use24HourFormat: use24Hour);
    _repository.saveSettings(_settings);
    notifyListeners();
  }

  /// Clock pattern honouring the 12h/24h preference.
  String get _clockPattern => _settings.use24HourFormat ? 'HH:mm' : 'hh:mm a';

  /// Same as [_clockPattern] but without the AM/PM marker — used where space
  /// is tight (the five-prayer-times row) so the font doesn't have to shrink
  /// to fit it.
  String get _clockPatternCompact =>
      _settings.use24HourFormat ? 'HH:mm' : 'hh:mm';

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat(_clockPattern).format(time);
  }

  /// Formats a fixed wall-clock time (e.g. the 08:00 log cutoff) per the
  /// current 12h/24h preference.
  String formatClock(int hour, [int minute = 0]) =>
      DateFormat(_clockPattern).format(DateTime(2000, 1, 1, hour, minute));

  /// Formats a raw "HH:mm" prayer-time string per the 12h/24h preference.
  /// Returns the input unchanged if it can't be parsed.
  String formatTimeString(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return hhmm;
    return formatClock(h, m);
  }

  /// Same as [formatTimeString] but without the AM/PM marker.
  String formatTimeStringCompact(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return hhmm;
    return DateFormat(_clockPatternCompact).format(DateTime(2000, 1, 1, h, m));
  }

  /// Fraction (0.0–1.0) of the way through the current Fajr-to-Fajr cycle at
  /// [now], or null when there isn't enough data to compute it. Pure/static
  /// so it's unit-testable and so the progress-bar widget can recompute it
  /// on its own timer tick without waiting for this provider to rebuild.
  ///
  /// We only fetch today's and tomorrow's Fajr (not yesterday's), so before
  /// today's Fajr has passed, the cycle start is approximated as
  /// `todayFajrTime - (tomorrowFajrTime - todayFajrTime)` — Fajr shifts by at
  /// most a minute or two day-to-day, which is invisible on a progress bar.
  static double? fajrCycleProgress({
    required DateTime? todayFajrTime,
    required DateTime? tomorrowFajrTime,
    required DateTime now,
  }) {
    if (todayFajrTime == null) return null;

    DateTime cycleStart;
    DateTime cycleEnd;
    if (now.isBefore(todayFajrTime)) {
      final approxDuration = tomorrowFajrTime != null
          ? tomorrowFajrTime.difference(todayFajrTime)
          : const Duration(hours: 24);
      cycleStart = todayFajrTime.subtract(approxDuration);
      cycleEnd = todayFajrTime;
    } else if (tomorrowFajrTime != null) {
      cycleStart = todayFajrTime;
      cycleEnd = tomorrowFajrTime;
    } else {
      return null;
    }

    final totalSeconds = cycleEnd.difference(cycleStart).inSeconds;
    if (totalSeconds <= 0) return null;

    final elapsedSeconds = now.difference(cycleStart).inSeconds;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// Time remaining until the next Fajr, or null when prayer times are
  /// unavailable. Formatting/localization happens at the widget layer.
  Duration? get untilNextFajr {
    DateTime? nextFajr;
    final now = DateTime.now();

    if (todayFajrTime != null && now.isBefore(todayFajrTime!)) {
      nextFajr = todayFajrTime;
    } else if (tomorrowFajrTime != null) {
      nextFajr = tomorrowFajrTime;
    }

    return nextFajr?.difference(now);
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
