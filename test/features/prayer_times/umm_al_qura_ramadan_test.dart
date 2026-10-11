import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/prayer_times/domain/umm_al_qura_ramadan.dart';

void main() {
  group('UmmAlQuraRamadan.contains', () {
    test('covers 1 Ramadan through the last day, not 1 Shawwal', () {
      // Ramadan 1447: 18 Feb – 19 Mar 2026.
      expect(UmmAlQuraRamadan.contains(DateTime(2026, 2, 17)), isFalse);
      expect(UmmAlQuraRamadan.contains(DateTime(2026, 2, 18)), isTrue);
      expect(UmmAlQuraRamadan.contains(DateTime(2026, 3, 19, 23, 59)), isTrue);
      expect(UmmAlQuraRamadan.contains(DateTime(2026, 3, 20)), isFalse);
    });

    test('handles a Ramadan that spans the new year', () {
      // Ramadan 1452: 26 Dec 2030 – 23 Jan 2031.
      expect(UmmAlQuraRamadan.contains(DateTime(2030, 12, 31)), isTrue);
      expect(UmmAlQuraRamadan.contains(DateTime(2031, 1, 23)), isTrue);
      expect(UmmAlQuraRamadan.contains(DateTime(2031, 1, 24)), isFalse);
    });

    test('falls back to the tabular calendar past the table', () {
      // Mid-Ramadan 1469 (15 Ramadan is 8 Jul 2047), far from either end.
      expect(UmmAlQuraRamadan.contains(DateTime(2047, 7, 10)), isTrue);
      expect(UmmAlQuraRamadan.contains(DateTime(2047, 9, 10)), isFalse);
    });
  });
}
