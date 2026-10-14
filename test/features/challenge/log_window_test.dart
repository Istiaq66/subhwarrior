import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/features/challenge/domain/log_window.dart';

void main() {
  const cutoff = AppConstants.logCutoffHour;

  group('nextLogWindowChange', () {
    test('before the cutoff, the window next closes at the cutoff', () {
      expect(
        nextLogWindowChange(DateTime(2026, 10, 14, 5, 25)),
        DateTime(2026, 10, 14, cutoff),
      );
    });

    test('just after midnight, the next change is still the cutoff', () {
      expect(
        nextLogWindowChange(DateTime(2026, 10, 14, 0, 0, 1)),
        DateTime(2026, 10, 14, cutoff),
      );
    });

    test('exactly at the cutoff, the next change is midnight', () {
      expect(
        nextLogWindowChange(DateTime(2026, 10, 14, cutoff)),
        DateTime(2026, 10, 15),
      );
    });

    test('in the afternoon, the window next opens at midnight', () {
      expect(
        nextLogWindowChange(DateTime(2026, 10, 14, 14, 38)),
        DateTime(2026, 10, 15),
      );
    });

    test('rolls over month and year ends', () {
      expect(
        nextLogWindowChange(DateTime(2026, 12, 31, 23, 59)),
        DateTime(2027),
      );
    });

    test('is always strictly in the future', () {
      for (var minute = 0; minute < 24 * 60; minute += 7) {
        final now = DateTime(2026, 10, 14).add(Duration(minutes: minute));
        expect(nextLogWindowChange(now).isAfter(now), isTrue, reason: '$now');
      }
    });
  });
}
