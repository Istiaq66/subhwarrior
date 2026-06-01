import '../domain/day_log.dart';
import '../../../core/constants/app_constants.dart';

/// Persisted snapshot of all challenge state. Plain data holder passed between
/// the controller and the data sources — no business logic, no I/O.
class ChallengeData {
  DateTime? challengeStartDate;
  bool isChallengeActive;
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
}
