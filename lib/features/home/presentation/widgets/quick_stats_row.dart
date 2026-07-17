import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';

/// Two-card row: days remaining and overall goal progress.
class QuickStatsRow extends StatelessWidget {
  final int daysRemaining;
  final double overallProgress;
  final int totalQualifyingDays;

  const QuickStatsRow({
    super.key,
    required this.daysRemaining,
    required this.overallProgress,
    required this.totalQualifyingDays,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$daysRemaining',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Days Left'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 30.0,
                    percent: overallProgress.clamp(0, 1),
                    center: Text('${(overallProgress * 100).toInt()}%'),
                    progressColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalQualifyingDays/${AppConstants.qualifyingDaysGoal}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Goal Progress'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Widget child;

  const _StatCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
