import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/utils/hijri_date.dart';

void main() {
  group('HijriDate.fromDateTime', () {
    test('maps the Islamic epoch to 1 Muharram 1', () {
      // The tabular epoch, 1 Muharram 1 AH, falls on 19 July 622 CE.
      expect(
        HijriDate.fromDateTime(DateTime(622, 7, 19)),
        const HijriDate(1, 1, 1),
      );
    });

    test('matches the start of Ramadan 1445', () {
      // Ramadan 1445 began on 11 March 2024 across most of the world, which
      // is a real-world check on the arithmetic rather than a self-check.
      expect(
        HijriDate.fromDateTime(DateTime(2024, 3, 11)),
        const HijriDate(1445, 9, 1),
      );
    });

    test('converts a known modern date', () {
      expect(
        HijriDate.fromDateTime(DateTime(2026, 9, 7)),
        const HijriDate(1448, 3, 24),
      );
    });

    test('advances exactly one day at a time across a month boundary', () {
      var previous = HijriDate.fromDateTime(DateTime(2026, 1, 1));
      for (var i = 1; i <= 400; i++) {
        final current =
            HijriDate.fromDateTime(DateTime(2026, 1, 1).add(Duration(days: i)));
        final rolledDay = current.day == previous.day + 1;
        final rolledMonth = current.day == 1 &&
            (current.month == previous.month + 1 ||
                (current.month == 1 && previous.month == 12));
        expect(
          rolledDay || rolledMonth,
          isTrue,
          reason: 'day $i went from $previous to $current',
        );
        previous = current;
      }
    });

    test('month is always within range over a long span', () {
      for (var i = 0; i < 4000; i += 7) {
        final hijri =
            HijriDate.fromDateTime(DateTime(2020, 1, 1).add(Duration(days: i)));
        expect(hijri.month, inInclusiveRange(1, 12));
        expect(hijri.day, inInclusiveRange(1, 30));
      }
    });
  });
}
