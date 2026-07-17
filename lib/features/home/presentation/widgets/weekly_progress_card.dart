import 'package:flutter/material.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';

/// Per-week qualifying-day progress bars for the challenge.
class WeeklyProgressCard extends StatelessWidget {
  final Map<int, int> weeklyProgress;
  final int currentWeek;

  const WeeklyProgressCard({
    super.key,
    required this.weeklyProgress,
    required this.currentWeek,
  });

  /// Qualifying days needed per week (16 goal / 4 weeks = 4).
  static const int _weeklyTarget =
      AppConstants.qualifyingDaysGoal ~/ AppConstants.challengeWeeks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weeklyProgressTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...List.generate(AppConstants.challengeWeeks, (index) {
              final week = index + 1;
              final progress = weeklyProgress[week] ?? 0;
              final isCurrentWeek = currentWeek == week;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.weeklyProgressWeekLabel(week),
                          style: TextStyle(
                            fontWeight: isCurrentWeek
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Text(l10n.weeklyProgressRatio(progress, _weeklyTarget)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress / _weeklyTarget,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= _weeklyTarget
                            ? context.appColors.success
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
