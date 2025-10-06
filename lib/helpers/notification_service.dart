import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Tapped notification with payload: ${response.payload}");
      },
    );
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
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Schedule Fajr reminder based on prayer time
  static Future<void> scheduleFajrReminder({
    required DateTime? fajrTime,
    required int minutesBefore,
  }) async {
    try {
      final now = DateTime.now();
      // Subtract reminder minutes
      var reminderDateTime = fajrTime?.subtract(Duration(minutes: minutesBefore));

      // If the reminder time has already passed today, schedule for tomorrow
      if (reminderDateTime!.isBefore(now)) {
        reminderDateTime = reminderDateTime.add(const Duration(days: 1));
      }

      // Convert to TZDateTime for local timezone
      final scheduledTime = tz.TZDateTime.from(reminderDateTime, tz.local);

      await scheduleNotification(
        id: 2,
        title: '🕌 Fajr in $minutesBefore minutes',
        body: 'Time to wake up for Fajr prayer!',
        scheduledDate: scheduledTime,
        payload: 'fajr_reminder',
      );

      debugPrint('Fajr reminder scheduled for: $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling Fajr reminder: $e');
    }
  }

  // Schedule daily logging reminder at 7:30 AM
  static Future<void> scheduleLoggingReminder() async {
    try {
      final now = DateTime.now();

      // Create reminder time at 7:30 AM
      var reminderTime = DateTime(now.year, now.month, now.day, 7, 30);

      // If 7:30 AM has passed today, schedule for tomorrow
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }

      // Convert to TZDateTime for local timezone
      final scheduledTime = tz.TZDateTime.from(reminderTime, tz.local);

      await scheduleNotification(
        id: 3,
        title: '⏰ Time to Log Your Day!',
        body: 'You have 30 minutes left to log your morning routine',
        scheduledDate: scheduledTime,
        payload: 'logging_reminder',
      );

      debugPrint('Logging reminder scheduled for: $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling logging reminder: $e');
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
    if (!notificationsEnabled) {
      // Cancel all if notifications disabled
      await cancelAllNotifications();
      return;
    }

    // Handle Fajr reminder
    if (fajrReminder && todayFajrTime != null) {
      await cancelNotification(2); // Cancel old one
      await scheduleFajrReminder(
        fajrTime: todayFajrTime,
        minutesBefore: fajrReminderMinutes,
      );
    } else {
      await cancelNotification(2);
    }

    // Handle logging reminder
    if (loggingReminder && isChallengeActive) {
      await cancelNotification(3); // Cancel old one
      await scheduleLoggingReminder();
    } else {
      await cancelNotification(3);
    }
  }

}
