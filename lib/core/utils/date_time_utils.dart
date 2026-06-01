/// Centralized date/week math. Previously `_isSameDay`, week-number and
/// "next Sunday" were duplicated across challenge_provider, progress_screen
/// and home (IMPROVEMENT_PLAN B4). One source of truth.
class AppDateUtils {
  AppDateUtils._();

  /// Whether two [DateTime]s fall on the same calendar day (ignores time).
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Strips the time component, returning midnight of the same day.
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The next Sunday strictly after [from] (defaults to now). Used as the
  /// challenge start date so it always begins on a week boundary.
  static DateTime nextSunday(DateTime from) {
    final daysUntilSunday = DateTime.sunday - from.weekday;
    if (daysUntilSunday <= 0) {
      return from.add(Duration(days: 7 + daysUntilSunday));
    }
    return from.add(Duration(days: daysUntilSunday));
  }

  /// Whole days elapsed between [startDate] and [date].
  static int daysSinceStart(DateTime startDate, DateTime date) =>
      date.difference(startDate).inDays;

  /// 1-based challenge week number for [date], given [startDate].
  /// Returns 1 when there is no start date.
  static int weekNumber(DateTime? startDate, DateTime date) {
    if (startDate == null) return 1;
    return (daysSinceStart(startDate, date) ~/ 7) + 1;
  }
}
