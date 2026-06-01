import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_time_utils.dart';
import '../data/challenge_data.dart';
import '../data/challenge_repository.dart';
import '../domain/day_log.dart';
import '../domain/log_result.dart';
import '../domain/sleep_preparation.dart';
import '../domain/work_type.dart';

/// Hour (24h) after which the daily logging window is closed.
/// Kept as a top-level const for backward compatibility with existing imports.
const int kLogCutoffHour = AppConstants.logCutoffHour;

/// Thin controller over [ChallengeRepository]. Holds no SharedPreferences,
/// Firestore or HTTP instances directly (IMPROVEMENT_PLAN B3) — all I/O goes
/// through the repository. Business rules live here; persistence does not.
class ChallengeProvider extends ChangeNotifier {
  final ChallengeRepository _repository;
  late ChallengeData _data;

  // Sleep tracking is in-memory only (parity with prior behavior).
  final Map<DateTime, SleepPreparation> _sleepPreparations = {};

  ChallengeProvider(this._repository) {
    _data = _repository.load();
  }

  /// Convenience constructor used by app wiring — builds the default
  /// repository from [prefs]. Keeps `ChangeNotifierProvider` call sites simple.
  factory ChallengeProvider.fromPrefs(SharedPreferences prefs) =>
      ChallengeProvider(ChallengeRepositoryImpl.fromPrefs(prefs));

  // Getters
  DateTime? get challengeStartDate => _data.challengeStartDate;
  List<DayLog> get dayLogs => _data.dayLogs;
  int get currentStreak => _data.currentStreak;
  int get totalQualifyingDays => _data.totalQualifyingDays;
  int get currentWeek => _data.currentWeek;
  bool get isChallengeActive => _data.isChallengeActive;
  String get userName => _data.userName;
  String get userLocation => _data.userLocation;
  double get userLatitude => _data.userLatitude;
  double get userLongitude => _data.userLongitude;

  /// Whether the user has set a real location. Do NOT infer this from
  /// `lat == 0 && lon == 0`: (0, 0) is a valid coordinate (Gulf of Guinea).
  bool get hasLocation => _data.hasLocation;
  bool get notificationsEnabled => _data.notificationsEnabled;
  bool get fajrReminder => _data.fajrReminder;
  bool get loggingReminder => _data.loggingReminder;
  int get fajrReminderMinutes => _data.fajrReminderMinutes;

  // Progress
  double get overallProgress =>
      _data.totalQualifyingDays / AppConstants.qualifyingDaysGoal;
  int get daysRemaining => AppConstants.challengeDays - _getDaysSinceStart();

  Map<int, int> get weeklyProgress {
    final progress = {
      for (var w = 1; w <= AppConstants.challengeWeeks; w++) w: 0
    };
    for (final log in _data.dayLogs) {
      if (log.isQualifying) {
        final week =
            AppDateUtils.weekNumber(_data.challengeStartDate, log.date);
        progress[week] = (progress[week] ?? 0) + 1;
      }
    }
    return progress;
  }

  /// Start a new challenge. Begins today (not the next Sunday): habit apps live
  /// on momentum, and the prior next-Sunday logic forced a week-long wait when
  /// the user joined on a Sunday. Weeks are rolling 7-day windows from today;
  /// the weekday-only / weekend-skip rules are unaffected.
  Future<void> startChallenge() async {
    _data.challengeStartDate = AppDateUtils.dateOnly(DateTime.now());
    _data.isChallengeActive = true;
    _data.dayLogs = [];
    _data.currentStreak = 0;
    _data.totalQualifyingDays = 0;
    _data.currentWeek = 1;

    await _repository.save(_data);
    notifyListeners();
  }

  Future<void> endChallenge() async {
    _data.isChallengeActive = false;
    await _repository.save(_data);
    notifyListeners();
  }

  /// Log a day's completion. Returns a typed [LogResult] so the UI can explain
  /// exactly why a log was rejected instead of a bare `false`.
  Future<LogResult> logDay({
    required bool prayedFajrOnTime,
    required bool prayedAtMasjid,
    required int minutesWorked,
    required String workDescription,
    required WorkType workType,
    String? reflection,
  }) async {
    final now = DateTime.now();

    // Logging window closes at 8 AM (08:00 is already closed).
    if (now.hour >= AppConstants.logCutoffHour) {
      return LogResult.afterCutoff;
    }

    // Weekends don't qualify.
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return LogResult.weekend;
    }

    // Only one log per day.
    final today = AppDateUtils.dateOnly(now);
    if (_data.dayLogs.any((log) => AppDateUtils.isSameDay(log.date, today))) {
      return LogResult.alreadyLogged;
    }

    final isQualifying = prayedFajrOnTime &&
        minutesWorked >= AppConstants.minDeepWorkMinutes &&
        workType.isQualifying;

    final log = DayLog(
      date: now,
      prayedFajrOnTime: prayedFajrOnTime,
      prayedAtMasjid: prayedAtMasjid,
      minutesWorked: minutesWorked,
      workDescription: workDescription,
      workType: workType,
      reflection: reflection,
      isQualifying: isQualifying,
      loggedAt: now,
    );

    _data.dayLogs.add(log);

    if (isQualifying) {
      _data.totalQualifyingDays++;
      _updateStreak();
    } else {
      _data.currentStreak = 0;
    }

    _data.currentWeek = AppDateUtils.weekNumber(_data.challengeStartDate, now);

    await _repository.save(_data);
    notifyListeners();

    return LogResult.success;
  }

  /// Log sleep preparation for the next day (in-memory only).
  Future<void> logSleepPreparation({
    required DateTime bedTime,
    required bool noScreens60Min,
    required bool hydratedWell,
    required bool avoidedCaffeine4Hours,
  }) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateKey = AppDateUtils.dateOnly(tomorrow);

    _sleepPreparations[dateKey] = SleepPreparation(
      bedTime: bedTime,
      noScreens60Min: noScreens60Min,
      hydratedWell: hydratedWell,
      avoidedCaffeine4Hours: avoidedCaffeine4Hours,
    );

    notifyListeners();
  }

  Future<bool> checkUsernameExists(String username) =>
      _repository.usernameExists(username, _data.userName);

  Future<void> updateUserSettings({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    if (name != _data.userName) {
      final exists = await checkUsernameExists(name);
      if (exists) {
        throw Exception('Username already taken. Please choose another name.');
      }
    }
    _data.userName = name;
    _data.userLocation = location;
    _data.userLatitude = latitude;
    _data.userLongitude = longitude;
    _data.hasLocation = location.trim().isNotEmpty;

    await _repository.save(_data);
    notifyListeners();
  }

  bool canLogToday() {
    final now = DateTime.now();
    if (now.hour >= AppConstants.logCutoffHour) return false;

    final today = AppDateUtils.dateOnly(now);
    return !_data.dayLogs.any((log) => AppDateUtils.isSameDay(log.date, today));
  }

  DayLog? getTodayLog() {
    final today = DateTime.now();
    try {
      return _data.dayLogs
          .firstWhere((log) => AppDateUtils.isSameDay(log.date, today));
    } catch (e) {
      return null;
    }
  }

  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool fajrReminder,
    required bool loggingReminder,
    required int fajrReminderMinutes,
  }) async {
    _data.notificationsEnabled = notificationsEnabled;
    _data.fajrReminder = fajrReminder;
    _data.loggingReminder = loggingReminder;
    _data.fajrReminderMinutes = fajrReminderMinutes;

    // Notification prefs don't belong in the leaderboard doc — local only.
    await _repository.saveLocal(_data);
    notifyListeners();
  }

  // Private helpers
  void _updateStreak() {
    _data.currentStreak = 0;
    final sortedLogs = List<DayLog>.from(_data.dayLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    DateTime? lastDate;
    for (final log in sortedLogs) {
      if (!log.isQualifying) break;

      if (lastDate == null) {
        _data.currentStreak = 1;
        lastDate = log.date;
      } else {
        final difference = lastDate.difference(log.date).inDays;
        if (difference == 1) {
          _data.currentStreak++;
          lastDate = log.date;
        } else {
          break;
        }
      }
    }
  }

  int _getDaysSinceStart() {
    if (_data.challengeStartDate == null) return 0;
    return AppDateUtils.daysSinceStart(
        _data.challengeStartDate!, DateTime.now());
  }
}
