import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/helpers/notification_service.dart';

void main() {
  group('computeFajrReminderTime', () {
    final fajr = DateTime(2026, 7, 17, 4, 30);

    test('schedules minutesBefore ahead of Fajr when still in the future', () {
      final result = NotificationService.computeFajrReminderTime(
        fajrTime: fajr,
        minutesBefore: 15,
        now: DateTime(2026, 7, 17, 2),
      );
      expect(result, DateTime(2026, 7, 17, 4, 15));
    });

    test('clamps negative minutesBefore to zero', () {
      final result = NotificationService.computeFajrReminderTime(
        fajrTime: fajr,
        minutesBefore: -30,
        now: DateTime(2026, 7, 17, 2),
      );
      expect(result, fajr);
    });

    test('rolls over to the next day when the reminder already passed', () {
      final result = NotificationService.computeFajrReminderTime(
        fajrTime: fajr,
        minutesBefore: 15,
        now: DateTime(2026, 7, 17, 4, 20),
      );
      expect(result, DateTime(2026, 7, 18, 4, 15));
    });

    test('does not roll over when called exactly at the reminder time', () {
      final result = NotificationService.computeFajrReminderTime(
        fajrTime: fajr,
        minutesBefore: 15,
        now: DateTime(2026, 7, 17, 4, 15),
      );
      expect(result, DateTime(2026, 7, 17, 4, 15));
    });

    test('handles rollover across a month boundary', () {
      final endOfMonthFajr = DateTime(2026, 7, 31, 4, 30);
      final result = NotificationService.computeFajrReminderTime(
        fajrTime: endOfMonthFajr,
        minutesBefore: 15,
        now: DateTime(2026, 7, 31, 5),
      );
      expect(result, DateTime(2026, 8, 1, 4, 15));
    });
  });

  group('computeLoggingReminderTime', () {
    test('schedules for today when the reminder time has not passed', () {
      final result = NotificationService.computeLoggingReminderTime(
        DateTime(2026, 7, 17, 6),
      );
      expect(
        result,
        DateTime(2026, 7, 17, AppConstants.logReminderHour,
            AppConstants.logReminderMinute),
      );
    });

    test('rolls over to tomorrow when the reminder time has passed', () {
      final result = NotificationService.computeLoggingReminderTime(
        DateTime(2026, 7, 17, 9),
      );
      expect(
        result,
        DateTime(2026, 7, 18, AppConstants.logReminderHour,
            AppConstants.logReminderMinute),
      );
    });

    test('does not roll over when called exactly at the reminder time', () {
      final now = DateTime(2026, 7, 17, AppConstants.logReminderHour,
          AppConstants.logReminderMinute);
      final result = NotificationService.computeLoggingReminderTime(now);
      expect(result, now);
    });
  });
}
