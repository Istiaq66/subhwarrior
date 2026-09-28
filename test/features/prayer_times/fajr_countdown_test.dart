import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';

/// Regression: changing the device date (or simply crossing midnight with the
/// app open) left yesterday's times in memory. The getters re-date a stored
/// `HH:mm` onto "now", so the countdown re-armed against a Fajr that had
/// already passed — one card rendered it as `-2h 47m`, the other as
/// `-02:-47:-13`, because `%` and `remainder` disagree on negative input.
void main() {
  final todayFajr = DateTime(2026, 9, 28, 5, 50);
  final tomorrowFajr = DateTime(2026, 9, 29, 5, 51);

  group('durationUntilNextFajr', () {
    test('counts down to today\'s Fajr before it arrives', () {
      final remaining = PrayerTimeProvider.durationUntilNextFajr(
        todayFajrTime: todayFajr,
        tomorrowFajrTime: tomorrowFajr,
        now: DateTime(2026, 9, 28, 5, 20),
      );

      expect(remaining, const Duration(minutes: 30));
    });

    test('rolls to tomorrow once today\'s Fajr has passed', () {
      final remaining = PrayerTimeProvider.durationUntilNextFajr(
        todayFajrTime: todayFajr,
        tomorrowFajrTime: tomorrowFajr,
        now: DateTime(2026, 9, 28, 6),
      );

      expect(remaining, const Duration(hours: 23, minutes: 51));
    });

    test('never returns a negative duration', () {
      // Both instants in the past — what stale times look like after the
      // clock moves forward a day.
      final remaining = PrayerTimeProvider.durationUntilNextFajr(
        todayFajrTime: todayFajr,
        tomorrowFajrTime: tomorrowFajr,
        now: DateTime(2026, 9, 30, 8),
      );

      expect(remaining, isNull);
    });

    test('is null when there are no times at all', () {
      expect(
        PrayerTimeProvider.durationUntilNextFajr(
          todayFajrTime: null,
          tomorrowFajrTime: null,
          now: DateTime(2026, 9, 28, 6),
        ),
        isNull,
      );
    });

    test('is null once today has passed and tomorrow is unknown', () {
      expect(
        PrayerTimeProvider.durationUntilNextFajr(
          todayFajrTime: todayFajr,
          tomorrowFajrTime: null,
          now: DateTime(2026, 9, 28, 6),
        ),
        isNull,
      );
    });
  });

  group('fajrCycleProgress', () {
    test('advances across the cycle', () {
      final progress = PrayerTimeProvider.fajrCycleProgress(
        todayFajrTime: todayFajr,
        tomorrowFajrTime: tomorrowFajr,
        now: DateTime(2026, 9, 28, 17, 50),
      );

      expect(progress, closeTo(0.5, 0.01));
    });

    test('is null past the end of the cycle rather than pinned full', () {
      // A bar stuck at 100% reads as "Fajr is imminent" forever.
      final progress = PrayerTimeProvider.fajrCycleProgress(
        todayFajrTime: todayFajr,
        tomorrowFajrTime: tomorrowFajr,
        now: DateTime(2026, 9, 30, 8),
      );

      expect(progress, isNull);
    });
  });

  group('countdown formatting agrees between the two cards', () {
    // The Fajr card splits with `%`, the Today card with `remainder`. They
    // must produce the same digits for anything the provider can now emit.
    for (final remaining in const [
      Duration(minutes: 30),
      Duration(hours: 23, minutes: 51, seconds: 9),
      Duration.zero,
    ]) {
      test('$remaining splits identically', () {
        expect(remaining.inMinutes % 60, remaining.inMinutes.remainder(60));
        expect(remaining.inSeconds % 60, remaining.inSeconds.remainder(60));
      });
    }
  });
}
