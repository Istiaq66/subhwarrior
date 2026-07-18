import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/providers/locale_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initBackground() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _setNotification();
  }

  Future<void> _setNotification() async {
    await _configureLocalTimeZone();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    String timezoneName;
    try {
      final TimezoneInfo timezone = await FlutterTimezone.getLocalTimezone();
      timezoneName = timezone.identifier;
    } on PlatformException {
      timezoneName = 'Asia/Dhaka';
    }
    tz.setLocalLocation(tz.getLocation(timezoneName));
  }

  /// Resolves localized strings without a BuildContext: honours the user's
  /// in-app language choice, falling back to the device locale (or English
  /// when that locale is unsupported).
  static Future<AppLocalizations> _loadL10n() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(LocaleProvider.prefsKey);
    var locale =
        stored != null ? Locale(stored) : PlatformDispatcher.instance.locale;
    if (!AppLocalizations.delegate.isSupported(locale)) {
      locale = const Locale('en');
    }
    return lookupAppLocalizations(locale);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final l10n = await _loadL10n();
    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      l10n.notifChannelGeneralName,
      channelDescription: l10n.notifChannelGeneralDesc,
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    final l10n = await _loadL10n();
    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      l10n.notifChannelScheduledName,
      channelDescription: l10n.notifChannelScheduledDesc,
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: androidDetails),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('✅ All notifications cancelled');
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('✅ Notification ID $id cancelled');
  }

  /// Pure scheduling math for the Fajr reminder: [minutesBefore] is clamped
  /// to >= 0, and a reminder already in the past rolls over to the next day.
  static DateTime computeFajrReminderTime({
    required DateTime fajrTime,
    required int minutesBefore,
    required DateTime now,
  }) {
    final safeMinutesBefore = minutesBefore < 0 ? 0 : minutesBefore;
    var reminderDateTime =
        fajrTime.subtract(Duration(minutes: safeMinutesBefore));
    if (reminderDateTime.isBefore(now)) {
      reminderDateTime = reminderDateTime.add(const Duration(days: 1));
    }
    return reminderDateTime;
  }

  /// Pure scheduling math for the daily logging reminder: today at the
  /// configured reminder time, rolling over to tomorrow once it has passed.
  static DateTime computeLoggingReminderTime(DateTime now) {
    var reminderTime = DateTime(now.year, now.month, now.day,
        AppConstants.logReminderHour, AppConstants.logReminderMinute);
    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }
    return reminderTime;
  }

  // Schedule Fajr reminder based on prayer time
  static Future<void> scheduleFajrReminder({
    required DateTime? fajrTime,
    required int minutesBefore,
  }) async {
    if (fajrTime == null) {
      debugPrint('❌ Cannot schedule Fajr reminder: fajrTime is null');
      return;
    }

    // Guard against negative/zero offsets (would push the reminder *after*
    // Fajr instead of before it).
    final safeMinutesBefore = minutesBefore < 0 ? 0 : minutesBefore;

    try {
      final now = DateTime.now();

      debugPrint('📅 Current time: $now');
      debugPrint('🕌 Fajr time provided: $fajrTime');

      final reminderDateTime = computeFajrReminderTime(
        fajrTime: fajrTime,
        minutesBefore: safeMinutesBefore,
        now: now,
      );
      debugPrint('⏰ Reminder time: $reminderDateTime');

      // Convert to TZDateTime for local timezone
      final scheduledTime = tz.TZDateTime.from(reminderDateTime, tz.local);

      debugPrint('✅ FAJR NOTIFICATION SCHEDULED FOR: $scheduledTime');
      debugPrint('   Timezone: ${scheduledTime.timeZoneName}');
      debugPrint(
          '   Time until notification: ${scheduledTime.difference(now)}');

      final l10n = await _loadL10n();
      await scheduleNotification(
        id: 2,
        title: l10n.notifFajrTitle(safeMinutesBefore),
        body: l10n.notifFajrBody,
        scheduledDate: scheduledTime,
        payload: 'fajr_reminder',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling Fajr reminder: $e');
    }
  }

  // Schedule daily logging reminder at 7:30 AM
  static Future<void> scheduleLoggingReminder() async {
    try {
      final now = DateTime.now();

      debugPrint('📅 Current time: $now');

      final reminderTime = computeLoggingReminderTime(now);
      debugPrint('⏰ Reminder time: $reminderTime');

      // Convert to TZDateTime for local timezone
      final scheduledTime = tz.TZDateTime.from(reminderTime, tz.local);

      debugPrint('✅ LOGGING NOTIFICATION SCHEDULED FOR: $scheduledTime');
      debugPrint('   Timezone: ${scheduledTime.timeZoneName}');
      debugPrint(
          '   Time until notification: ${scheduledTime.difference(now)}');

      final l10n = await _loadL10n();
      await scheduleNotification(
        id: 3,
        title: l10n.notifLogTitle,
        body: l10n.notifLogBody,
        scheduledDate: scheduledTime,
        payload: 'logging_reminder',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling logging reminder: $e');
    }
  }

  // Centralized method to update all notifications based on settings
  static Future<void> updateNotifications({
    required bool notificationsEnabled,
    required bool fajrReminder,
    required bool loggingReminder,
    required int fajrReminderMinutes,
    DateTime? todayFajrTime,
    required bool isChallengeActive,
  }) async {
    debugPrint('🔔 ========== UPDATING NOTIFICATIONS ==========');
    debugPrint('   Notifications Enabled: $notificationsEnabled');
    debugPrint('   Fajr Reminder: $fajrReminder');
    debugPrint('   Logging Reminder: $loggingReminder');
    debugPrint('   Fajr Reminder Minutes: $fajrReminderMinutes');
    debugPrint('   Today Fajr Time: $todayFajrTime');
    debugPrint('   Challenge Active: $isChallengeActive');

    if (!notificationsEnabled) {
      debugPrint('🔕 Notifications disabled - cancelling all');
      await cancelAllNotifications();
      return;
    }

    // Handle Fajr reminder
    if (fajrReminder && todayFajrTime != null) {
      debugPrint('🕌 Setting up Fajr reminder...');
      await cancelNotification(2);
      await scheduleFajrReminder(
        fajrTime: todayFajrTime,
        minutesBefore: fajrReminderMinutes,
      );
    } else {
      debugPrint('🚫 Fajr reminder disabled or no time available');
      await cancelNotification(2);
    }

    // Handle logging reminder
    if (loggingReminder && isChallengeActive) {
      debugPrint('📝 Setting up logging reminder...');
      await cancelNotification(3);
      await scheduleLoggingReminder();
    } else {
      debugPrint('🚫 Logging reminder disabled or challenge inactive');
      await cancelNotification(3);
    }

    debugPrint('🔔 ========================================');
    printPendingNotifications();
  }

  // Check what notifications are currently scheduled
  static Future<void> printPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    debugPrint('📋 ========== PENDING NOTIFICATIONS ==========');
    if (pending.isEmpty) {
      debugPrint('   No pending notifications');
    } else {
      for (var notification in pending) {
        debugPrint('   ID: ${notification.id}');
        debugPrint('   Title: ${notification.title}');
        debugPrint('   Body: ${notification.body}');
        debugPrint('   ---');
      }
    }
    debugPrint('📋 ==========================================');
  }
}
