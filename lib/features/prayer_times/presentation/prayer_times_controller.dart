import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/fajr_widget_service.dart';
import '../data/prayer_times_repository.dart';
import '../domain/cached_prayer_times.dart';
import '../domain/prayer_settings.dart';
import '../domain/prayer_times.dart';

/// Where the times currently on screen came from. Lets the UI tell "nothing
/// yet" (show a loading state) apart from "yesterday's fetch, revalidating"
/// (show the times, no spinner).
enum PrayerTimesSource { none, cache, network }

/// Thin controller over [PrayerTimesRepository]. Holds no http, Geolocator or
/// SharedPreferences instances directly (IMPROVEMENT_PLAN B3) — all I/O goes
/// through the repository. Time-window math and formatting live here.
///
/// Startup is stale-while-revalidate: the constructor hydrates from the local
/// cache synchronously (like [PrayerTimesRepository.loadSettings]) so Home can
/// paint real times on its first frame, and the network refresh then runs
/// behind that. Nothing about startup waits on the network — see
/// [loadForProfile].
class PrayerTimeProvider extends ChangeNotifier {
  final PrayerTimesRepository _repository;

  PrayerTimes? _todayPrayerTimes;
  PrayerTimes? _tomorrowPrayerTimes;
  bool _isLoading = false;
  String _error = '';
  PrayerSettings _settings;
  PrayerTimesSource _source = PrayerTimesSource.none;

  /// The cache entry the current [_todayPrayerTimes] came from, kept so a
  /// later fetch can tell whether those times belong to the location now
  /// being used. Cleared once fresh data lands.
  CachedPrayerTimes? _hydratedFrom;

  PrayerTimeProvider(this._repository)
      : _settings = _repository.loadSettings() {
    _hydrateFromCache();
  }

  /// Convenience constructor used by app wiring.
  factory PrayerTimeProvider.fromPrefs(SharedPreferences prefs) =>
      PrayerTimeProvider(PrayerTimesRepositoryImpl.fromPrefs(prefs));

  /// Populates state from the cache when it is still today's. The location
  /// check has to wait for a caller that knows which location is in play
  /// (see [loadForProfile]) — showing the wrong *day* is the error worth
  /// blocking here, and a wrong location is corrected before any fetch.
  void _hydrateFromCache() {
    final cached = _repository.loadCachedTimes();
    if (cached == null || !cached.isSameDayAs(DateTime.now())) return;

    _todayPrayerTimes = cached.today;
    _tomorrowPrayerTimes = cached.tomorrow;
    _hydratedFrom = cached;
    _source = PrayerTimesSource.cache;
  }

  PrayerTimes? get todayPrayerTimes => _todayPrayerTimes;
  PrayerTimes? get tomorrowPrayerTimes => _tomorrowPrayerTimes;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Whether there is anything to render, from either source.
  bool get hasTimes => _todayPrayerTimes != null;

  /// Provenance of the times on screen.
  PrayerTimesSource get source => _source;
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

  /// Fetches by coordinates.
  ///
  /// Rejects 0,0 outright: that is the app's "no coordinates yet" sentinel
  /// (see `ChallengeProvider.hasUsableCoordinates`), and the Aladhan API
  /// answers it with HTTP 400, so sending it only produces a generic failure
  /// card. Callers should fall back to a city or device-location lookup.
  Future<void> fetchPrayerTimes(double latitude, double longitude) async {
    if (latitude == 0.0 && longitude == 0.0) {
      _error = 'No coordinates set';
      _notifyDeferred();
      return;
    }
    _dropCacheIfElsewhere(latitude: latitude, longitude: longitude);
    await _runFetch(() async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      _todayPrayerTimes = await _repository.fetchByCoordinates(
          today, latitude, longitude, _settings);
      _tomorrowPrayerTimes = await _repository.fetchByCoordinates(
          tomorrow, latitude, longitude, _settings);
      await _cacheCurrent(latitude: latitude, longitude: longitude);
    });
  }

  Future<void> fetchPrayerTimesByCity(String city, String country) async {
    // A city lookup has no coordinates of its own, so it caches against the
    // profile's 0,0 sentinel — the same key it will present on next launch,
    // and one that stops matching the moment real coordinates arrive.
    _dropCacheIfElsewhere(latitude: 0.0, longitude: 0.0);
    await _runFetch(() async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      _todayPrayerTimes =
          await _repository.fetchByCity(today, city, country, _settings);
      _tomorrowPrayerTimes =
          await _repository.fetchByCity(tomorrow, city, country, _settings);
      await _cacheCurrent(latitude: 0.0, longitude: 0.0);
    });
  }

  /// Resolution ladder shared by Home and app startup: real coordinates when
  /// the profile has them, else a city lookup off the stored location name,
  /// else — only when [allowDeviceLocation] — ask the device.
  ///
  /// Startup passes `allowDeviceLocation: false`: a GPS permission dialog over
  /// the splash screen has no context, so that rung stays on the Home path
  /// where the user can see what is asking and why.
  Future<void> loadForProfile({
    required bool hasLocation,
    required bool hasUsableCoordinates,
    required double latitude,
    required double longitude,
    ({String city, String country})? cityCountry,
    bool allowDeviceLocation = true,
  }) async {
    if (!hasLocation) return;

    if (hasUsableCoordinates) {
      await fetchPrayerTimes(latitude, longitude);
      return;
    }

    if (cityCountry != null) {
      await fetchPrayerTimesByCity(cityCountry.city, cityCountry.country);
      return;
    }

    if (allowDeviceLocation) {
      await fetchPrayerTimesForCurrentLocation();
    }
  }

  /// Drops cache-hydrated times that belong to a different place, so a stale
  /// location's times are never on screen while the new one is fetched.
  void _dropCacheIfElsewhere({
    required double latitude,
    required double longitude,
  }) {
    final hydrated = _hydratedFrom;
    if (hydrated == null) return;
    if (hydrated.matchesLocation(latitude: latitude, longitude: longitude)) {
      return;
    }

    _todayPrayerTimes = null;
    _tomorrowPrayerTimes = null;
    _hydratedFrom = null;
    _source = PrayerTimesSource.none;
  }

  /// Persists whatever was just fetched. Only reached on a successful fetch,
  /// so a failed refresh can never overwrite a good entry.
  Future<void> _cacheCurrent({
    required double latitude,
    required double longitude,
  }) async {
    final today = _todayPrayerTimes;
    final tomorrow = _tomorrowPrayerTimes;
    if (today == null || tomorrow == null) return;

    _hydratedFrom = null;
    _source = PrayerTimesSource.network;
    await _repository.saveCachedTimes(CachedPrayerTimes(
      today: today,
      tomorrow: tomorrow,
      date: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    ));
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

    return nextFajr?.difference(now);
  }

  /// Shared fetch wrapper: toggles loading/error and defers notifications to
  /// avoid notifying during a build frame.
  Future<void> _runFetch(Future<void> Function() body) async {
    // With cached times already on screen this is a background revalidation:
    // flipping `isLoading` would swap real data for a spinner, which is the
    // flash the cache exists to prevent.
    final isRevalidation = hasTimes;
    _isLoading = !isRevalidation;
    _error = '';
    _notifyDeferred();

    try {
      await body();
      unawaited(FajrWidgetService.refresh());
    } catch (e) {
      // Offline with a usable cache: keep showing it rather than replacing it
      // with an error card. The error surfaces only when there is nothing
      // else to show.
      if (isRevalidation) {
        debugPrint('PrayerTimeProvider: refresh failed, keeping cache: $e');
      } else {
        _error = 'Failed to fetch prayer times: $e';
      }
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
