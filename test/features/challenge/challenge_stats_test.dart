import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/features/challenge/domain/challenge_stats.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';

void main() {
  // The completion comp reports days completed, best streak, total minutes and
  // masjid days plus a per-week bar. Only the first was tracked on
  // ChallengeData; the rest are derived from the logs here.
  group('ChallengeStats.fromLogs', () {
    final start = DateTime(2026, 9, 6); // a Sunday

    DayLog log(
      DateTime date, {
      bool qualifying = true,
      int minutes = 60,
      bool masjid = false,
    }) =>
        DayLog(
          date: date,
          prayedFajrOnTime: qualifying,
          prayedAtMasjid: masjid,
          minutesWorked: minutes,
          workDescription: 'work',
          workType: WorkType.deepWork,
          isQualifying: qualifying,
          loggedAt: date,
        );

    test('returns zeroes and empty bars with no logs', () {
      final stats = ChallengeStats.fromLogs([], challengeStartDate: start);

      expect(stats.daysCompleted, 0);
      expect(stats.bestStreak, 0);
      expect(stats.totalMinutes, 0);
      expect(stats.masjidDays, 0);
      expect(stats.weeklyProgress, hasLength(AppConstants.challengeWeeks));
      expect(stats.weeklyProgress, everyElement(0.0));
    });

    test('counts only qualifying days as completed', () {
      final stats = ChallengeStats.fromLogs([
        log(start),
        log(start.add(const Duration(days: 1)), qualifying: false),
        log(start.add(const Duration(days: 2))),
      ], challengeStartDate: start);

      expect(stats.daysCompleted, 2);
    });

    test('sums minutes across every log, qualifying or not', () {
      final stats = ChallengeStats.fromLogs([
        log(start, minutes: 90),
        log(start.add(const Duration(days: 1)),
            qualifying: false, minutes: 30),
      ], challengeStartDate: start);

      expect(stats.totalMinutes, 120);
    });

    test('counts masjid days from the flag, not from qualifying', () {
      final stats = ChallengeStats.fromLogs([
        log(start, masjid: true),
        log(start.add(const Duration(days: 1)),
            qualifying: false, masjid: true),
        log(start.add(const Duration(days: 2))),
      ], challengeStartDate: start);

      expect(stats.masjidDays, 2);
    });

    group('best streak', () {
      test('is the longest consecutive run, not the last one', () {
        final stats = ChallengeStats.fromLogs([
          // A three-day run...
          log(start),
          log(start.add(const Duration(days: 1))),
          log(start.add(const Duration(days: 2))),
          // ...a gap, then a shorter run.
          log(start.add(const Duration(days: 5))),
          log(start.add(const Duration(days: 6))),
        ], challengeStartDate: start);

        expect(stats.bestStreak, 3);
      });

      test('is 1 when no two qualifying days touch', () {
        final stats = ChallengeStats.fromLogs([
          log(start),
          log(start.add(const Duration(days: 2))),
          log(start.add(const Duration(days: 4))),
        ], challengeStartDate: start);

        expect(stats.bestStreak, 1);
      });

      test('ignores non-qualifying days that would bridge a gap', () {
        final stats = ChallengeStats.fromLogs([
          log(start),
          log(start.add(const Duration(days: 1)), qualifying: false),
          log(start.add(const Duration(days: 2))),
        ], challengeStartDate: start);

        expect(stats.bestStreak, 1);
      });
    });

    group('weekly progress', () {
      test('fills a week at the per-week qualifying target', () {
        final stats = ChallengeStats.fromLogs([
          for (var i = 0; i < ChallengeStats.qualifyingDaysPerWeek; i++)
            log(start.add(Duration(days: i))),
        ], challengeStartDate: start);

        expect(stats.weeklyProgress.first, 1.0);
        expect(stats.weeklyProgress.skip(1), everyElement(0.0));
      });

      test('reports a part-week as a fraction', () {
        final stats = ChallengeStats.fromLogs(
          [log(start)],
          challengeStartDate: start,
        );

        expect(
          stats.weeklyProgress.first,
          1 / ChallengeStats.qualifyingDaysPerWeek,
        );
      });

      test('clamps a week that beat its target to a full bar', () {
        final stats = ChallengeStats.fromLogs([
          for (var i = 0; i < 7; i++) log(start.add(Duration(days: i))),
        ], challengeStartDate: start);

        expect(stats.weeklyProgress.first, 1.0);
      });

      test('buckets later logs into their own week', () {
        final stats = ChallengeStats.fromLogs([
          log(start),
          log(start.add(const Duration(days: 7))), // week 2
          log(start.add(const Duration(days: 21))), // week 4
        ], challengeStartDate: start);

        expect(stats.weeklyProgress[0], greaterThan(0));
        expect(stats.weeklyProgress[1], greaterThan(0));
        expect(stats.weeklyProgress[2], 0.0);
        expect(stats.weeklyProgress[3], greaterThan(0));
      });

      test('keeps out-of-window logs in the totals but off the chart', () {
        final stats = ChallengeStats.fromLogs([
          log(start.add(const Duration(days: 40))), // past week 4
        ], challengeStartDate: start);

        expect(stats.daysCompleted, 1);
        expect(stats.weeklyProgress, everyElement(0.0));
      });
    });
  });
}
