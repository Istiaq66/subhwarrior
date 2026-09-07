import '../../../core/constants/app_constants.dart';
import '../domain/day_log.dart';

/// Persisted snapshot of all challenge state. Plain data holder passed between
/// the controller and the data sources — no business logic, no I/O.
class ChallengeData {
  DateTime? challengeStartDate;
  bool isChallengeActive;
  bool hasUnseenCompletion;
  int currentStreak;
  int totalQualifyingDays;
  int currentWeek;

  String userName;
  String userLocation;
  double userLatitude;
  double userLongitude;
  bool hasLocation;

  bool notificationsEnabled;
  bool fajrReminder;
  bool loggingReminder;
  int fajrReminderMinutes;

  List<DayLog> dayLogs;

  ChallengeData({
    this.challengeStartDate,
    this.isChallengeActive = false,
    this.hasUnseenCompletion = false,
    this.currentStreak = 0,
    this.totalQualifyingDays = 0,
    this.currentWeek = 1,
    this.userName = '',
    this.userLocation = '',
    this.userLatitude = 0.0,
    this.userLongitude = 0.0,
    this.hasLocation = false,
    this.notificationsEnabled = true,
    this.fajrReminder = true,
    this.loggingReminder = true,
    this.fajrReminderMinutes = AppConstants.defaultFajrReminderMinutes,
    List<DayLog>? dayLogs,
  }) : dayLogs = dayLogs ?? [];

  /// Whether the stored coordinates can actually be used for a prayer-times
  /// lookup.
  ///
  /// `0` is what the app itself writes when it has no coordinates —
  /// `AuthScreen` calls `updateUserSettings(latitude: 0, longitude: 0)` after
  /// sign-up, and a remote profile saved without coordinates restores as
  /// `0.0`. So a profile can carry a real city name alongside 0,0, and the
  /// prayer-times API rejects 0,0 with HTTP 400. This distinguishes "we have
  /// coordinates" from "we have a location" so callers can fall back to a
  /// city lookup instead of failing.
  bool get hasUsableCoordinates => userLatitude != 0.0 || userLongitude != 0.0;

  /// [userLocation] split into a city/country pair usable for a by-city
  /// prayer-times lookup ("Mountain View, United States"), or null when the
  /// stored name is a bare city or empty.
  ({String city, String country})? get cityCountry {
    final parts = userLocation.split(',');
    if (parts.length < 2) return null;
    final city = parts.first.trim();
    final country = parts.sublist(1).join(',').trim();
    if (city.isEmpty || country.isEmpty) return null;
    return (city: city, country: country);
  }
}
