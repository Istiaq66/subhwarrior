import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/fajr_widget_service.dart';
import '../data/prayer_times_repository.dart';
import '../domain/country_prayer_defaults.dart';
import '../domain/prayer_settings.dart';
import '../domain/prayer_times.dart';

/// Thin controller over [PrayerTimesRepository]. Holds no Geolocator or
/// SharedPreferences instances directly (IMPROVEMENT_PLAN B3) — all I/O goes
/// through the repository. Time-window math and formatting live here.
///
/// Times are calculated on the device, so app startup computes them before
/// Home's first frame — see [loadForProfile].
class PrayerTimeProvider extends ChangeNotifier {
  final PrayerTimesRepository _repository;

  PrayerTimes? _todayPrayerTimes;
  PrayerTimes? _tomorrowPrayerTimes;
  bool _isLoading = false;
  String _error = '';
  PrayerSettings _settings;

  /// The calendar day [_todayPrayerTimes] describes.
  ///
  /// Without it, yesterday's times quietly became today's: the getters below
  /// re-anchor a stored `HH:mm` onto whatever "now" is, so at midnight (or a
  /// device clock change) the countdown re-armed against the previous day's
  /// Fajr instead of going stale.
  DateTime? _timesDay;

  PrayerTimeProvider(this._repository) : _settings = _repository.loadSettings();

  /// Convenience constructor used by app wiring.
  factory PrayerTimeProvider.fromPrefs(SharedPreferences prefs) =>
      PrayerTimeProvider(PrayerTimesRepositoryImpl.fromPrefs(prefs));

  /// Midnight of [moment] — the day two instants are compared on.
  static DateTime _dayOf(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  /// Whether the times in memory describe a day other than today's.
  ///
  /// True after midnight passes with the app still open, and after a device
  /// clock change. Everything derived from the times is withheld while it
  /// holds, rather than being re-dated onto the new day.
  bool get hasStaleTimes {
    final day = _timesDay;
    return day != null && day != _dayOf(DateTime.now());
  }

  PrayerTimes? get todayPrayerTimes => _todayPrayerTimes;
  PrayerTimes? get tomorrowPrayerTimes => _tomorrowPrayerTimes;
  bool get isLoading => _isLoading;
  String get error => _error;

  bool get hasTimes => _todayPrayerTimes != null;

  int get calculationMethod => _settings.calculationMethod;
  bool get useHanafiMethod => _settings.useHanafiMethod;
  bool get use24HourFormat => _settings.use24HourFormat;

  DateTime? get todayFajrTime {
    if (_todayPrayerTimes == null || hasStaleTimes) return null;
    return _onDay(DateTime.now(), _todayPrayerTimes!.fajr);
  }

  DateTime? get tomorrowFajrTime {
    if (_tomorrowPrayerTimes == null || hasStaleTimes) return null;
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

  /// Fetches by coordinates.
  ///
  /// Rejects 0,0 outright: that is the app's "no coordinates yet" sentinel
  /// (see `ChallengeProvider.hasUsableCoordinates`), and calculating for it
  /// would show the Gulf of Guinea's times as the user's. Callers should fall
  /// back to a device-location lookup.
  Future<void> fetchPrayerTimes(double latitude, double longitude) async {
    if (latitude == 0.0 && longitude == 0.0) {
      _error = 'No coordinates set';
      _notifyDeferred();
      return;
    }
    await _runFetch(() async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      _todayPrayerTimes = await _repository.fetchByCoordinates(
          today, latitude, longitude, _settings);
      _tomorrowPrayerTimes = await _repository.fetchByCoordinates(
          tomorrow, latitude, longitude, _settings);
      _timesDay = _dayOf(today);
    });
  }

  /// Resolution ladder shared by Home and app startup: the profile's
  /// coordinates when it has them, else — only when [allowDeviceLocation] —
  /// the device's.
  ///
  /// Startup passes `allowDeviceLocation: false`: a GPS permission dialog over
  /// the splash screen has no context, so that rung stays on the Home path
  /// where the user can see what is asking and why.
  Future<void> loadForProfile({
    required bool hasLocation,
    required bool hasUsableCoordinates,
    required double latitude,
    required double longitude,
    bool allowDeviceLocation = true,
  }) async {
    if (!hasLocation) return;

    if (hasUsableCoordinates) {
      await fetchPrayerTimes(latitude, longitude);
      return;
    }

    if (allowDeviceLocation) {
      await fetchPrayerTimesForCurrentLocation();
    }
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

  /// Adopts the calculation method customary in [countryCode] (ISO 3166-1
  /// alpha-2) and, when [seed], its Asr school (see [CountryPrayerDefaults]).
  ///
  /// Onboarding seeds: a new profile takes both outright. After that only a
  /// move to another country re-applies the method — re-detecting in the same
  /// country keeps whatever the user picked, and the school, a personal
  /// choice, is never touched again. A profile from before country defaults
  /// has nothing recorded; its first location change only records the
  /// country, so the method its user is already on survives.
  ///
  /// A null code (the geocoder had no answer, or was offline) changes
  /// nothing. Does not refetch; callers fetch for the new location after.
  Future<void> applyCountryDefaults(
    String? countryCode, {
    bool seed = false,
  }) async {
    final code = countryCode?.trim().toUpperCase();
    if (code == null || code.isEmpty) return;

    final previous = _settings.defaultsCountryCode;
    if (!seed && previous == code) return;

    final defaults = CountryPrayerDefaults.forCountry(code);
    final adopt = seed || previous != null;
    _settings = _settings.copyWith(
      defaultsCountryCode: code,
      calculationMethod: adopt ? defaults.calculationMethod : null,
      useHanafiMethod: seed ? defaults.useHanafiMethod : null,
    );
    await _repository.saveSettings(_settings);
    notifyListeners();
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

    // Past the end of the cycle the times are stale, and a bar pinned at 100%
    // reads as "Fajr is imminent" forever. Say nothing instead.
    if (now.isAfter(cycleEnd)) return null;

    final elapsedSeconds = now.difference(cycleStart).inSeconds;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// Time remaining until the next Fajr, or null when prayer times are
  /// unavailable. Formatting/localization happens at the widget layer.
  Duration? get untilNextFajr => durationUntilNextFajr(
        todayFajrTime: todayFajrTime,
        tomorrowFajrTime: tomorrowFajrTime,
        now: DateTime.now(),
      );

  /// Pure/static twin of [untilNextFajr] — lets the live-ticking countdown
  /// widget recompute the remaining time on its own timer tick without
  /// waiting for this provider to rebuild.
  static Duration? durationUntilNextFajr({
    required DateTime? todayFajrTime,
    required DateTime? tomorrowFajrTime,
    required DateTime now,
  }) {
    DateTime? nextFajr;

    if (todayFajrTime != null && now.isBefore(todayFajrTime)) {
      nextFajr = todayFajrTime;
    } else if (tomorrowFajrTime != null) {
      nextFajr = tomorrowFajrTime;
    }

    if (nextFajr == null) return null;

    // A next Fajr in the past means the times are stale, not that Fajr was
    // minus two hours ago. Callers render null as "unknown"; a negative
    // `Duration` rendered as a clock, and each card mangled the sign
    // differently.
    final remaining = nextFajr.difference(now);
    return remaining.isNegative ? null : remaining;
  }

  /// Shared fetch wrapper: toggles loading/error and defers notifications to
  /// avoid notifying during a build frame.
  Future<void> _runFetch(Future<void> Function() body) async {
    // Recalculating under times already on screen must not flash a spinner.
    _isLoading = !hasTimes;
    _error = '';
    _notifyDeferred();

    try {
      await body();
      unawaited(FajrWidgetService.refresh());
    } catch (e) {
      _error = 'Failed to calculate prayer times: $e';
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
