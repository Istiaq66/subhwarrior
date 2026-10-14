import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/prayer_times/data/fajr_call_service.dart';

void main() {
  group('nextOccurrence', () {
    test('keeps today\'s Fajr when it is still ahead', () {
      final fajr = DateTime(2026, 9, 28, 5, 12);
      final now = DateTime(2026, 9, 28, 3);

      expect(
        FajrCallService.nextOccurrence(fajrTime: fajr, now: now),
        fajr,
      );
    });

    test('rolls over to tomorrow once today\'s Fajr has passed', () {
      final fajr = DateTime(2026, 9, 28, 5, 12);
      final now = DateTime(2026, 9, 28, 7);

      expect(
        FajrCallService.nextOccurrence(fajrTime: fajr, now: now),
        DateTime(2026, 9, 29, 5, 12),
      );
    });

    test('rolls over when now is exactly Fajr — the call already rang', () {
      final fajr = DateTime(2026, 9, 28, 5, 12);

      expect(
        FajrCallService.nextOccurrence(fajrTime: fajr, now: fajr),
        DateTime(2026, 9, 29, 5, 12),
      );
    });

    test('crosses a month boundary', () {
      final fajr = DateTime(2026, 9, 30, 5, 20);
      final now = DateTime(2026, 9, 30, 6);

      expect(
        FajrCallService.nextOccurrence(fajrTime: fajr, now: now),
        DateTime(2026, 10, 1, 5, 20),
      );
    });
  });

  test('the caller is named Namaz', () {
    expect(FajrCallService.callerName, 'Namaz');
  });

  group('off Android', () {
    // The host test VM is not Android, so every entry point should be inert
    // rather than reaching for a plugin channel that is not registered.
    test('scheduling, cancelling and launch checks are no-ops', () async {
      await expectLater(
        FajrCallService.schedule(
          enabled: true,
          fajrTime: DateTime.now().add(const Duration(hours: 1)),
        ),
        completes,
      );
      await expectLater(FajrCallService.cancel(), completes);
      await expectLater(FajrCallService.restoreFromLaunch(), completes);
      expect(await FajrCallService.canShowFullScreen(), isFalse);
      expect(await FajrCallService.canScheduleExactAlarms(), isFalse);
    });

    test('ignores notification responses', () {
      const response = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: FajrCallService.notificationId,
        payload: 'flutter_alarm_call:{}',
      );

      expect(FajrCallService.handleResponse(response), isFalse);
    });
  });
}
