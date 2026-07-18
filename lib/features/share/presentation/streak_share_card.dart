import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/l10n_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Fixed-size, self-contained visual for the shareable streak image.
/// No interactivity — designed to be wrapped in a [RepaintBoundary].
class StreakShareCard extends StatelessWidget {
  const StreakShareCard({
    super.key,
    required this.currentStreak,
    required this.totalQualifyingDays,
    required this.currentWeek,
  });

  final int currentStreak;
  final int totalQualifyingDays;
  final int currentWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Container(
      width: 320,
      height: 400,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.appColors.streakGradient,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mosque, color: onPrimary, size: 28),
              AppSpacing.hGapSm,
              Flexible(
                child: Text(
                  l10n.shareCardTitle,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Icon(Icons.local_fire_department, color: onPrimary, size: 48),
              Text(
                context.localizeNumber(currentStreak),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                l10n.shareCardStreakLabel,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: onPrimary),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                context.localizeNumber(totalQualifyingDays),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                l10n.shareCardQualifyingLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: onPrimary),
              ),
              AppSpacing.vGapSm,
              Text(
                l10n.shareCardWeekLabel(currentWeek),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: onPrimary),
              ),
            ],
          ),
          Text(
            l10n.shareCardFooter,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: onPrimary),
          ),
        ],
      ),
    );
  }
}
