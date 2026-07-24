import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/day_log.dart';
import 'challenge_data.dart';

/// Reads/writes challenge state to [SharedPreferences]. The only place that
/// knows the prefs key names and serialization format.
class ChallengeLocalDataSource {
  final SharedPreferences prefs;

  final String uid;

  ChallengeLocalDataSource(this.prefs, {this.uid = ''});

  // Prefs keys — single source of truth (base names, before uid namespacing).
  static const _kStartDate = 'challengeStartDate';
  static const _kActive = 'isChallengeActive';
  static const _kHasUnseenCompletion = 'hasUnseenCompletion';
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

  /// Marker so the legacy migration runs at most once per device.
  static const _kMigrated = '__challenge_ns_migrated_v1__';

  /// Every base key, used by the migration.
  static const List<String> _allKeys = [
    _kStartDate,
    _kActive,
    _kHasUnseenCompletion,
    _kStreak,
    _kTotalQualifying,
    _kWeek,
    _kUserName,
    _kUserLocation,
    _kLatitude,
    _kLongitude,
    _kHasLocation,
    _kNotifications,
    _kFajrReminder,
    _kLoggingReminder,
    _kFajrReminderMinutes,
    _kDayLogs,
  ];

  String _key(String base) => uid.isEmpty ? base : '$uid:$base';

  static Future<void> migrateLegacyIfNeeded(
      SharedPreferences prefs, String uid) async {
    if (uid.isEmpty) return;
    if (prefs.getBool(_kMigrated) ?? false) return;

    for (final base in _allKeys) {
      if (!prefs.containsKey(base)) continue;
      final target = '$uid:$base';
      if (prefs.containsKey(target)) continue;
      final value = prefs.get(base);
      if (value is String) {
        await prefs.setString(target, value);
      } else if (value is int) {
        await prefs.setInt(target, value);
      } else if (value is double) {
        await prefs.setDouble(target, value);
      } else if (value is bool) {
        await prefs.setBool(target, value);
      }
    }
    await prefs.setBool(_kMigrated, true);
  }

  ChallengeData load() {
    final data = ChallengeData();

    final startDateStr = prefs.getString(_key(_kStartDate));
    if (startDateStr != null) {
      data.challengeStartDate = DateTime.parse(startDateStr);
    }

    data.isChallengeActive = prefs.getBool(_key(_kActive)) ?? false;
    data.hasUnseenCompletion =
        prefs.getBool(_key(_kHasUnseenCompletion)) ?? false;
    data.currentStreak = prefs.getInt(_key(_kStreak)) ?? 0;
    data.totalQualifyingDays = prefs.getInt(_key(_kTotalQualifying)) ?? 0;
    data.currentWeek = prefs.getInt(_key(_kWeek)) ?? 1;

    data.userName = prefs.getString(_key(_kUserName)) ?? '';
    data.userLocation = prefs.getString(_key(_kUserLocation)) ?? '';
    data.userLatitude = prefs.getDouble(_key(_kLatitude)) ?? 0.0;
    data.userLongitude = prefs.getDouble(_key(_kLongitude)) ?? 0.0;
    data.hasLocation =
        prefs.getBool(_key(_kHasLocation)) ?? data.userLocation.isNotEmpty;

    data.notificationsEnabled = prefs.getBool(_key(_kNotifications)) ?? true;
    data.fajrReminder = prefs.getBool(_key(_kFajrReminder)) ?? true;
    data.loggingReminder = prefs.getBool(_key(_kLoggingReminder)) ?? true;
    data.fajrReminderMinutes = prefs.getInt(_key(_kFajrReminderMinutes)) ??
        AppConstants.defaultFajrReminderMinutes;

    final logsJson = prefs.getString(_key(_kDayLogs));
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
          _key(_kStartDate), data.challengeStartDate!.toIso8601String());
    }

    await prefs.setBool(_key(_kActive), data.isChallengeActive);
    await prefs.setBool(_key(_kHasUnseenCompletion), data.hasUnseenCompletion);
    await prefs.setInt(_key(_kStreak), data.currentStreak);
    await prefs.setInt(_key(_kTotalQualifying), data.totalQualifyingDays);
    await prefs.setInt(_key(_kWeek), data.currentWeek);

    await prefs.setString(_key(_kUserName), data.userName);
    await prefs.setString(_key(_kUserLocation), data.userLocation);
    await prefs.setDouble(_key(_kLatitude), data.userLatitude);
    await prefs.setDouble(_key(_kLongitude), data.userLongitude);
    await prefs.setBool(_key(_kHasLocation), data.hasLocation);

    await prefs.setBool(_key(_kNotifications), data.notificationsEnabled);
    await prefs.setBool(_key(_kFajrReminder), data.fajrReminder);
    await prefs.setBool(_key(_kLoggingReminder), data.loggingReminder);
    await prefs.setInt(_key(_kFajrReminderMinutes), data.fajrReminderMinutes);

    final logsJson = json.encode(data.dayLogs.map((e) => e.toJson()).toList());
    await prefs.setString(_key(_kDayLogs), logsJson);
  }
}
