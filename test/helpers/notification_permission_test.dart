import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/helpers/notification_permission.dart';

void main() {
  final now = DateTime(2026, 10, 15, 9);

  group('with reminders or the call switched on', () {
    test('asks on any launch, not just the cadence ones', () {
      // A reinstall restores the switches from the account but not the OS
      // permission; launch 4 is off-cadence and used to be skipped.
      expect(
        shouldPromptForNotifications(
          featuresNeedIt: true,
          launchCount: 4,
          now: now,
        ),
        isTrue,
      );
    });

    test('keeps asking past the cadence limit', () {
      expect(
        shouldPromptForNotifications(
          featuresNeedIt: true,
          launchCount: 120,
          now: now,
        ),
        isTrue,
      );
    });

    test('holds off while snoozed', () {
      expect(
        shouldPromptForNotifications(
          featuresNeedIt: true,
          launchCount: 4,
          now: now,
          snoozedUntil: now.add(const Duration(hours: 1)),
        ),
        isFalse,
      );
    });

    test('asks again once the snooze has run out', () {
      expect(
        shouldPromptForNotifications(
          featuresNeedIt: true,
          launchCount: 4,
          now: now,
          snoozedUntil: now,
        ),
        isTrue,
      );
    });
  });

  group('with nothing that needs notifications', () {
    test('nudges on launches 1, 11, 21 and 31 only', () {
      final asked = [
        for (var launch = 1; launch <= 40; launch++)
          if (shouldPromptForNotifications(
            featuresNeedIt: false,
            launchCount: launch,
            now: now,
          ))
            launch,
      ];

      expect(asked, [1, 11, 21, 31]);
    });
  });
}
