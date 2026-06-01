import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/day_log.dart';
import 'challenge_data.dart';

/// Reads/writes challenge state to [SharedPreferences]. The only place that
/// knows the prefs key names and serialization format.
class ChallengeLocalDataSource {
  final SharedPreferences prefs;

  ChallengeLocalDataSource(this.prefs);

  // Prefs keys — single source of truth.
  static const _kStartDate = 'challengeStartDate';
  static const _kActive = 'isChallengeActive';
  static const _kStreak = 'currentStreak';
  static const _kTotalQualifying = 'totalQualifyingDays';
  static const _kWeek = 'currentWeek';
  static const _kUserName = 'userName';
  static const _kUserLocation = 'userLocation';
  static const _kLatitude = 'userLatitude';
  static const _kLongitude = 'userLongitude';
  static const _kHasLocation = 'hasLocation';
  static const _kNotifications = 'notifications_enabled';
  static const _kFajrReminder = 'fajr_reminder';
  static const _kLoggingReminder = 'logging_reminder';
  static const _kFajrReminderMinutes = 'fajr_reminder_minutes';
  static const _kDayLogs = 'dayLogs';

  ChallengeData load() {
    final data = ChallengeData();

    final startDateStr = prefs.getString(_kStartDate);
    if (startDateStr != null) {
      data.challengeStartDate = DateTime.parse(startDateStr);
    }

    data.isChallengeActive = prefs.getBool(_kActive) ?? false;
    data.currentStreak = prefs.getInt(_kStreak) ?? 0;
    data.totalQualifyingDays = prefs.getInt(_kTotalQualifying) ?? 0;
    data.currentWeek = prefs.getInt(_kWeek) ?? 1;

    data.userName = prefs.getString(_kUserName) ?? '';
    data.userLocation = prefs.getString(_kUserLocation) ?? '';
    data.userLatitude = prefs.getDouble(_kLatitude) ?? 0.0;
    data.userLongitude = prefs.getDouble(_kLongitude) ?? 0.0;
    data.hasLocation =
        prefs.getBool(_kHasLocation) ?? data.userLocation.isNotEmpty;

    data.notificationsEnabled = prefs.getBool(_kNotifications) ?? true;
    data.fajrReminder = prefs.getBool(_kFajrReminder) ?? true;
    data.loggingReminder = prefs.getBool(_kLoggingReminder) ?? true;
    data.fajrReminderMinutes = prefs.getInt(_kFajrReminderMinutes) ??
        AppConstants.defaultFajrReminderMinutes;

    final logsJson = prefs.getString(_kDayLogs);
    if (logsJson != null) {
      final logsList = json.decode(logsJson) as List;
      data.dayLogs = logsList
          .map((e) => DayLog.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return data;
  }

  Future<void> save(ChallengeData data) async {
    if (data.challengeStartDate != null) {
      await prefs.setString(
          _kStartDate, data.challengeStartDate!.toIso8601String());
    }

    await prefs.setBool(_kActive, data.isChallengeActive);
    await prefs.setInt(_kStreak, data.currentStreak);
    await prefs.setInt(_kTotalQualifying, data.totalQualifyingDays);
    await prefs.setInt(_kWeek, data.currentWeek);

    await prefs.setString(_kUserName, data.userName);
    await prefs.setString(_kUserLocation, data.userLocation);
    await prefs.setDouble(_kLatitude, data.userLatitude);
    await prefs.setDouble(_kLongitude, data.userLongitude);
    await prefs.setBool(_kHasLocation, data.hasLocation);

    await prefs.setBool(_kNotifications, data.notificationsEnabled);
    await prefs.setBool(_kFajrReminder, data.fajrReminder);
    await prefs.setBool(_kLoggingReminder, data.loggingReminder);
    await prefs.setInt(_kFajrReminderMinutes, data.fajrReminderMinutes);

    final logsJson = json.encode(data.dayLogs.map((e) => e.toJson()).toList());
    await prefs.setString(_kDayLogs, logsJson);
  }
}
