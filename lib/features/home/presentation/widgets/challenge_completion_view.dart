import 'package:flutter/material.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';

/// Shown once, in place of [InactiveChallengeView], right after a challenge's
/// 28-day window auto-closes — recaps the final stats and offers to restart.
/// Stays on screen (re-shown on every app open) until the user taps restart;
/// there is no separate dismiss action (see the completion-screen design doc).
///
/// Laid out from the comp: a ringed celebration badge with a warm glow, the
/// headline pair, a "your journey" summary card, then the actions. The comp's
/// card shows four stats including minutes-focused and masjid days; this view
/// only receives the qualifying-day and streak totals, so it shows those two
/// and leaves the goal/week detail to the summary sentence.
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CelebrationBadge(goalMet: goalMet),
            AppSpacing.vGapXl,
            Text(
              goalMet
                  ? l10n.challengeCompleteTitleGoalMet
                  : l10n.challengeCompleteTitleFallShort,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: scheme.primary),
            ),
            AppSpacing.vGapSm,
            Text(
              l10n.challengeCompleteBody(
                totalQualifyingDays,
                AppConstants.qualifyingDaysGoal,
                finalStreak,
                currentWeek,
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            AppSpacing.vGapXl,
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _JourneyStat(
                            label: l10n.progressStatCompleted,
                            value: context.localizeNumber(totalQualifyingDays),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: scheme.outlineVariant,
                        ),
                        Expanded(
                          child: _JourneyStat(
                            label: l10n.progressStatStreak,
                            value: context.localizeNumber(finalStreak),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapXl,
            // Comp hierarchy: sharing is the primary action, restarting is the
            // quieter one beneath it.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: Text(l10n.shareCardButton),
              ),
            ),
            AppSpacing.vGapSm,
            TextButton(
              onPressed: onRestart,
              child: Text(l10n.challengeCompleteRestartButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// 128px primary disc with concentric mint rings and a warm glow behind it.
class _CelebrationBadge extends StatelessWidget {
  final bool goalMet;

  const _CelebrationBadge({required this.goalMet});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Warm glow, standing in for the comp's blurred `bg-warning/20`.
          Container(
            width: 152,
            height: 152,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appColors.warning.withValues(alpha: 0.18),
            ),
          ),
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary,
              border: Border.all(color: scheme.surface, width: 4),
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _Ring(size: 112, color: scheme.secondary.withValues(alpha: 0.5),
                    width: 2),
                _Ring(size: 96, color: scheme.secondary.withValues(alpha: 0.3),
                    width: 1),
                Icon(
                  goalMet ? Icons.workspace_premium : Icons.trending_up,
                  size: 48,
                  color: scheme.onPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double width;

  const _Ring({required this.size, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: width),
      ),
    );
  }
}

class _JourneyStat extends StatelessWidget {
  final String label;
  final String value;

  const _JourneyStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        AppSpacing.vGapXs,
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
