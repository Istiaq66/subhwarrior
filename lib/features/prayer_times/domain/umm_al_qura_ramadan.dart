// Table dates spell out day 1 to keep every row the same shape.
// ignore_for_file: avoid_redundant_argument_values

import '../../../core/utils/hijri_date.dart';

/// Whether a day falls in Ramadan by the Umm al-Qura calendar — the one the
/// Umm al-Qura prayer method's Ramadan Isha rule is defined against.
///
/// [HijriDate] is the tabular calendar and can be a day off at either end of
/// the month, which would move Isha by 30 minutes on that day. So the
/// Umm al-Qura month boundaries are tabulated here, as published by Aladhan's
/// calendar API (`/v1/hToG/<d-m-y>?calendarMethod=UAQ`); only years past the
/// table fall back to the tabular calendar.
abstract final class UmmAlQuraRamadan {
  /// Gregorian 1 Ramadan and 1 Shawwal (exclusive end), 1446–1462 AH.
  static final List<(DateTime, DateTime)> _months = [
    (DateTime(2025, 3, 1), DateTime(2025, 3, 30)),
    (DateTime(2026, 2, 18), DateTime(2026, 3, 20)),
    (DateTime(2027, 2, 8), DateTime(2027, 3, 9)),
    (DateTime(2028, 1, 28), DateTime(2028, 2, 26)),
    (DateTime(2029, 1, 16), DateTime(2029, 2, 14)),
    (DateTime(2030, 1, 5), DateTime(2030, 2, 4)),
    (DateTime(2030, 12, 26), DateTime(2031, 1, 24)),
    (DateTime(2031, 12, 15), DateTime(2032, 1, 14)),
    (DateTime(2032, 12, 4), DateTime(2033, 1, 2)),
    (DateTime(2033, 11, 23), DateTime(2033, 12, 23)),
    (DateTime(2034, 11, 12), DateTime(2034, 12, 12)),
    (DateTime(2035, 11, 1), DateTime(2035, 12, 1)),
    (DateTime(2036, 10, 20), DateTime(2036, 11, 19)),
    (DateTime(2037, 10, 10), DateTime(2037, 11, 8)),
    (DateTime(2038, 9, 30), DateTime(2038, 10, 29)),
    (DateTime(2039, 9, 19), DateTime(2039, 10, 19)),
    (DateTime(2040, 9, 7), DateTime(2040, 10, 7)),
  ];

  static const _ramadan = 9;

  /// [day]'s calendar date is what counts; its time of day is ignored.
  static bool contains(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    final covered =
        !date.isBefore(_months.first.$1) && date.isBefore(_months.last.$2);
    if (!covered) return HijriDate.fromDateTime(date).month == _ramadan;
    return _months
        .any((month) => !date.isBefore(month.$1) && date.isBefore(month.$2));
  }
}
