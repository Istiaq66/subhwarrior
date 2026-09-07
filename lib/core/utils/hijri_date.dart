/// Gregorian → Hijri conversion for the dashboard date line.
///
/// Uses the tabular ("civil"/Kuwaiti) Islamic calendar: pure arithmetic, no
/// lookup tables, no network and no extra dependency. That keeps the app's
/// offline guarantee intact and makes the conversion unit-testable.
///
/// Caveat worth knowing: the tabular calendar is arithmetic, not observational,
/// so it can differ by a day from a local moon-sighting announcement or from
/// Umm al-Qura. It is the right trade-off for a decorative date line, but do
/// not use it to decide when Ramadan starts.
class HijriDate {
  const HijriDate(this.year, this.month, this.day);

  /// 1-based year, month (1 = Muharram) and day.
  final int year;
  final int month;
  final int day;

  /// Julian Day Number of the Islamic epoch, 1 Muharram 1 AH.
  static const int _islamicEpochJdn = 1948440;

  static HijriDate fromDateTime(DateTime date) =>
      _fromJdn(_gregorianToJdn(date.year, date.month, date.day));

  /// Fliegel–Van Flandern conversion of a Gregorian date to a Julian Day
  /// Number.
  static int _gregorianToJdn(int year, int month, int day) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  static HijriDate _fromJdn(int jdn) {
    final shifted = jdn - _islamicEpochJdn + 10632;
    final cycles = ((shifted - 1) / 10631).floor();
    var remainder = shifted - 10631 * cycles + 354;
    final yearInCycle = (((10985 - remainder) / 5316).floor()) *
            (((50 * remainder) / 17719).floor()) +
        ((remainder / 5670).floor()) * (((43 * remainder) / 15238).floor());
    remainder = remainder -
        (((30 - yearInCycle) / 15).floor()) *
            (((17719 * yearInCycle) / 50).floor()) -
        ((yearInCycle / 16).floor()) *
            (((15238 * yearInCycle) / 43).floor()) +
        29;
    final month = ((24 * remainder) / 709).floor();
    final day = remainder - ((709 * month) / 24).floor();
    final year = 30 * cycles + yearInCycle - 30;
    return HijriDate(year, month, day);
  }

  @override
  String toString() => '$year-$month-$day';

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}
