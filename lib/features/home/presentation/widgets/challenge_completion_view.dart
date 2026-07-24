import 'package:flutter/material.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';

/// Shown once, in place of [InactiveChallengeView], right after a challenge's
/// 28-day window auto-closes — recaps the final stats and offers to restart.
/// Stays on screen (re-shown on every app open) until the user taps restart;
/// there is no separate dismiss action (see the completion-screen design doc).
class ChallengeCompletionView extends StatelessWidget {
  final bool goalMet;
  final int finalStreak;
  final int totalQualifyingDays;
  final int currentWeek;
  final VoidCallback onShare;
  final VoidCallback onRestart;

  const ChallengeCompletionView({
    super.key,
    required this.goalMet,
    required this.finalStreak,
    required this.totalQualifyingDays,
    required this.currentWeek,
    required this.onShare,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              goalMet ? Icons.emoji_events : Icons.trending_up,
              size: 100,
              color: goalMet ? scheme.primary : scheme.secondary,
            ),
            AppSpacing.vGapLg,
            Text(
              goalMet
                  ? l10n.challengeCompleteTitleGoalMet
                  : l10n.challengeCompleteTitleFallShort,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapMd,
            Text(
              l10n.challengeCompleteBody(
                totalQualifyingDays,
                AppConstants.qualifyingDaysGoal,
                finalStreak,
                currentWeek,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXl,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: Text(l10n.shareCardButton),
              ),
            ),
            AppSpacing.vGapMd,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.challengeCompleteRestartButton),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
