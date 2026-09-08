import '../../../core/utils/date_time_utils.dart';
import 'prayer_times.dart';

/// The last successfully fetched prayer times, stamped with the calendar date
/// and coordinates they were fetched for.
///
/// Both stamps are what make the cache safe to show: prayer times are only
/// correct for the day and place they were computed for, so a cache entry is
/// worthless — and actively misleading — once either has moved on. Nothing
/// reads these times without checking [isValidFor] first.
class CachedPrayerTimes {
  const CachedPrayerTimes({
    required this.today,
    required this.tomorrow,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  final PrayerTimes today;
  final PrayerTimes tomorrow;

  /// Calendar date (time component stripped) the times were fetched for.
  final DateTime date;

  /// Coordinates the fetch used. A city-name lookup has none, and stores the
  /// profile's `0, 0` sentinel — which still works as a cache key, because a
  /// profile that later gains real coordinates no longer matches it.
  final double latitude;
  final double longitude;

  /// How far coordinates may drift before the cache is considered to belong
  /// to somewhere else. ~0.01° is a little over a kilometre — comfortably
  /// past the jitter a GPS fix produces between launches, and far below any
  /// move that would shift prayer times perceptibly.
  static const double coordinateTolerance = 0.01;

  /// Whether these times can be shown as [now]'s times for the given
  /// coordinates.
  bool isValidFor({
    required DateTime now,
    required double latitude,
    required double longitude,
  }) =>
      isSameDayAs(now) &&
      matchesLocation(latitude: latitude, longitude: longitude);

  /// Whether the cache was fetched for [now]'s calendar date. Yesterday's Fajr
  /// shown as today's is wrong by minutes, which is exactly the kind of error
  /// this app cannot afford.
  bool isSameDayAs(DateTime now) =>
      AppDateUtils.isSameDay(date, AppDateUtils.dateOnly(now));

  bool matchesLocation({
    required double latitude,
    required double longitude,
  }) =>
      (this.latitude - latitude).abs() <= coordinateTolerance &&
      (this.longitude - longitude).abs() <= coordinateTolerance;

  Map<String, dynamic> toCacheMap() => {
        'date': AppDateUtils.dateOnly(date).toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'today': today.toCacheMap(),
        'tomorrow': tomorrow.toCacheMap(),
      };

  /// Returns null for anything unparseable, so a format change or a truncated
  /// write degrades to "no cache" rather than throwing on startup.
  static CachedPrayerTimes? fromCacheMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final rawToday = map['today'];
    final rawTomorrow = map['tomorrow'];
    if (rawDate is! String || rawToday is! Map || rawTomorrow is! Map) {
      return null;
    }

    final date = DateTime.tryParse(rawDate);
    if (date == null) return null;

    return CachedPrayerTimes(
      today: PrayerTimes.fromCacheMap(Map<String, dynamic>.from(rawToday)),
      tomorrow:
          PrayerTimes.fromCacheMap(Map<String, dynamic>.from(rawTomorrow)),
      date: AppDateUtils.dateOnly(date),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
