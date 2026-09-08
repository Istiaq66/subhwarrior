import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_time_utils.dart';
import 'day_log.dart';

/// End-of-challenge totals for the completion screen's summary card.
///
/// The comp's card reports four figures — days completed, best streak, total
/// minutes and masjid days — plus a per-week progress bar. Only the first was
/// already tracked on [ChallengeData]; the rest are derived here from the day
/// logs rather than stored, so they cannot drift out of sync with the logs
/// they summarise.
class ChallengeStats {
  const ChallengeStats({
    required this.daysCompleted,
    required this.bestStreak,
    required this.totalMinutes,
    required this.masjidDays,
    required this.weeklyProgress,
  });

  /// Qualifying days logged across the whole challenge.
  final int daysCompleted;

  /// Longest run of consecutive qualifying calendar days.
  final int bestStreak;

  /// Deep-work minutes summed over every log, qualifying or not — the user
  /// put the time in either way.
  final int totalMinutes;

  /// Days the user recorded praying at the masjid.
  final int masjidDays;

  /// Completion fraction (0..1) for each challenge week, in order. Always
  /// [AppConstants.challengeWeeks] long, so a week with nothing logged still
  /// draws an empty bar instead of vanishing.
  final List<double> weeklyProgress;

  /// Qualifying days that make up one full week's bar. The 16-day goal is
  /// four weeks of four qualifying weekdays, so a week is "full" at four.
  static const int qualifyingDaysPerWeek =
      AppConstants.qualifyingDaysGoal ~/ AppConstants.challengeWeeks;

  factory ChallengeStats.fromLogs(
    List<DayLog> logs, {
    required DateTime? challengeStartDate,
  }) {
    final qualifyingDates = <DateTime>{
      for (final log in logs)
        if (log.isQualifying) AppDateUtils.dateOnly(log.date),
    };

    final weeklyCounts = List<int>.filled(AppConstants.challengeWeeks, 0);
    for (final date in qualifyingDates) {
      final week = AppDateUtils.weekNumber(challengeStartDate, date);
      // A log outside the challenge window (or logged before the start date)
      // has no bar to land in — count it in the totals, not the chart.
      if (week >= 1 && week <= weeklyCounts.length) {
        weeklyCounts[week - 1]++;
      }
    }

    return ChallengeStats(
      daysCompleted: qualifyingDates.length,
      bestStreak: _bestStreak(qualifyingDates),
      totalMinutes: logs.fold(0, (sum, log) => sum + log.minutesWorked),
      masjidDays: logs.where((log) => log.prayedAtMasjid).length,
      weeklyProgress: [
        for (final count in weeklyCounts)
          (count / qualifyingDaysPerWeek).clamp(0.0, 1.0),
      ],
    );
  }

  /// Longest chain of consecutive days in [dates].
  static int _bestStreak(Set<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sorted = dates.toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].difference(sorted[i - 1]).inDays;
      run = gap == 1 ? run + 1 : 1;
      if (run > best) best = run;
    }
    return best;
  }
}
