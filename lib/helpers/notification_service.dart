import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      channelDescription: 'App notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled prayer/challenge reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(android: androidDetails),
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

  // Schedule Fajr reminder based on prayer time
  static Future<void> scheduleFajrReminder({
    required DateTime? fajrTime,
    required int minutesBefore,
  }) async {
    if (fajrTime == null) {
      debugPrint('❌ Cannot schedule Fajr reminder: fajrTime is null');
      return;
    }

    try {
      final now = DateTime.now();

      debugPrint('📅 Current time: $now');
      debugPrint('🕌 Fajr time provided: $fajrTime');

      // Subtract reminder minutes
      var reminderDateTime = fajrTime.subtract(Duration(minutes: minutesBefore));
      debugPrint('⏰ Initial reminder time: $reminderDateTime');

      // If the reminder time has already passed today, schedule for tomorrow
      if (reminderDateTime.isBefore(now)) {
        reminderDateTime = reminderDateTime.add(const Duration(days: 1));
        debugPrint('⏭️ Reminder time passed, moved to tomorrow: $reminderDateTime');
      }

      // Convert to TZDateTime for local timezone
      final scheduledTime = tz.TZDateTime.from(reminderDateTime, tz.local);

      debugPrint('✅ FAJR NOTIFICATION SCHEDULED FOR: $scheduledTime');
      debugPrint('   Timezone: ${scheduledTime.timeZoneName}');
      debugPrint('   Time until notification: ${scheduledTime.difference(now)}');

      await scheduleNotification(
        id: 2,
        title: '🕌 Fajr in $minutesBefore minutes',
        body: 'Time to wake up for Fajr prayer!',
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

      // Create reminder time at 7:30 AM
      var reminderTime = DateTime(now.year, now.month, now.day, 7, 30);
      debugPrint('⏰ Initial reminder time (7:30 AM): $reminderTime');

      // If 7:30 AM has passed today, schedule for tomorrow
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
        debugPrint('⏭️ 7:30 AM passed, moved to tomorrow: $reminderTime');
      }

      // Convert to TZDateTime for local timezone
      final scheduledTime = tz.TZDateTime.from(reminderTime, tz.local);

      debugPrint('✅ LOGGING NOTIFICATION SCHEDULED FOR: $scheduledTime');
      debugPrint('   Timezone: ${scheduledTime.timeZoneName}');
      debugPrint('   Time until notification: ${scheduledTime.difference(now)}');

      await scheduleNotification(
        id: 3,
        title: '⏰ Time to Log Your Day!',
        body: 'You have 30 minutes left to log your morning routine',
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