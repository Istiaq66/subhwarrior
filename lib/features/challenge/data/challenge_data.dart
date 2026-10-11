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
  bool fajrCall;
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
    // Opt-in: a ringing call over the lock screen is a bigger intrusion than
    // the notification, so an upgrading user keeps what they signed up for.
    this.fajrCall = false,
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
  /// `0.0`. So a profile can carry a real city name alongside 0,0, and
  /// calculating for 0,0 yields the Gulf of Guinea's times rather than that
  /// city's. This distinguishes "we have coordinates" from "we have a
  /// location".
  bool get hasUsableCoordinates => userLatitude != 0.0 || userLongitude != 0.0;
}
