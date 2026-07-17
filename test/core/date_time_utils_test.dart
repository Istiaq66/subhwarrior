import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/utils/date_time_utils.dart';

void main() {
  group('AppDateUtils.isSameDay', () {
    test('true for same calendar day, different time', () {
      expect(
        AppDateUtils.isSameDay(
          DateTime(2026, 6, 1, 5, 30),
          DateTime(2026, 6, 1, 23, 59),
        ),
        isTrue,
      );
    });

    test('false across midnight', () {
      expect(
        AppDateUtils.isSameDay(DateTime(2026, 6, 1), DateTime(2026, 6, 2)),
        isFalse,
      );
    });
  });

  group('AppDateUtils.dateOnly', () {
    test('strips the time component', () {
      expect(
        AppDateUtils.dateOnly(DateTime(2026, 6, 1, 7, 45, 12)),
        DateTime(2026, 6, 1),
      );
    });
  });

  group('AppDateUtils.nextSunday', () {
    test('returns the upcoming Sunday from a Wednesday', () {
      // 2026-06-03 is a Wednesday; next Sunday is 2026-06-07.
      final result = AppDateUtils.nextSunday(DateTime(2026, 6, 3));
      expect(result.weekday, DateTime.sunday);
      expect(result, DateTime(2026, 6, 7));
    });

    test('jumps a full week when called on a Sunday', () {
      // Documents the prior next-Sunday edge: starting on Sunday waits 7 days.
      // 2026-06-07 is a Sunday.
      final result = AppDateUtils.nextSunday(DateTime(2026, 6, 7));
      expect(result, DateTime(2026, 6, 14));
    });
  });

  group('AppDateUtils.weekNumber', () {
    final start = DateTime(2026, 6, 1);

    test('returns 1 with no start date', () {
      expect(AppDateUtils.weekNumber(null, DateTime(2026, 6, 20)), 1);
    });

    test('1-based: start day is week 1', () {
      expect(AppDateUtils.weekNumber(start, start), 1);
    });

    test('day 7 is still week 1, day 8 is week 2', () {
      expect(AppDateUtils.weekNumber(start, start.add(const Duration(days: 6))),
          1);
      expect(AppDateUtils.weekNumber(start, start.add(const Duration(days: 7))),
          2);
    });
  });
}
