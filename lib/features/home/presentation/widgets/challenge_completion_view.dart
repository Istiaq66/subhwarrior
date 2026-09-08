import 'package:flutter/material.dart';

import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';
import 'package:subh_warrior/features/challenge/domain/challenge_stats.dart';

/// Shown once, in place of [InactiveChallengeView], right after a challenge's
/// 28-day window auto-closes — recaps the final stats and offers to restart.
/// Stays on screen (re-shown on every app open) until the user taps restart;
/// there is no separate dismiss action (see the completion-screen design doc).
///
/// Laid out from the comp: a ringed celebration badge with a warm glow, the
/// headline pair, a four-row summary card, per-week progress bars, then the
/// actions.
///
/// One deliberate departure: the comp puts a close (✕) in a top app bar. This
/// screen has no dismiss action by design — it re-shows on every app open
/// until the user restarts — so there is nothing for that control to do and it
/// is left out.
class ChallengeCompletionView extends StatelessWidget {
  final bool goalMet;
  final ChallengeStats stats;
  final VoidCallback onShare;
  final VoidCallback onRestart;

  const ChallengeCompletionView({
    super.key,
    required this.goalMet,
    required this.stats,
    required this.onShare,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appColors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _CelebrationBadge(),
            AppSpacing.vGapLg,
            Text(
              l10n.challengeCompleteHeadline,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: scheme.onSurface),
            ),
            AppSpacing.vGapXs,
            Text(
              l10n.challengeCompleteSubtitle(AppConstants.challengeDays),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            AppSpacing.vGapLg,
            // Summary card: icon + label on the leading side, figure trailing.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.check_circle,
                      iconColor: scheme.secondary,
                      label: l10n.challengeStatDaysCompleted,
                      value: context.localizeNumber(stats.daysCompleted),
                      showDivider: true,
                    ),
                    _StatRow(
                      icon: Icons.local_fire_department,
                      iconColor: appColors.warning,
                      label: l10n.challengeStatBestStreak,
                      value: context.localizeNumber(stats.bestStreak),
                      // `text-streak-gradient` in the comp — the streak figure
                      // is the one number that carries the warm accent.
                      valueColor: appColors.streakGradientEnd,
                      showDivider: true,
                    ),
                    _StatRow(
                      icon: Icons.timer_outlined,
                      iconColor: scheme.secondary,
                      label: l10n.challengeStatTotalMinutes,
                      value: context.localizeNumber(stats.totalMinutes),
                      showDivider: true,
                    ),
                    _StatRow(
                      icon: Icons.mosque_outlined,
                      iconColor: scheme.secondary,
                      label: l10n.challengeStatMasjidDays,
                      value: context.localizeNumber(stats.masjidDays),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapMd,
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.weeklyProgressTitle.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    for (var i = 0; i < stats.weeklyProgress.length; i++)
                      _WeekBar(
                        label: l10n.weeklyProgressWeekAbbrev(i + 1),
                        value: stats.weeklyProgress[i],
                        isLast: i == stats.weeklyProgress.length - 1,
                      ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapLg,
            // Comp hierarchy: sharing is the primary action, restarting is the
            // quieter one beneath it.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.challengeCompleteShareButton),
              ),
            ),
            AppSpacing.vGapSm,
            TextButton(
              onPressed: onRestart,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onSurfaceVariant,
              ),
              child: Text(l10n.challengeCompleteRestartButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two nested discs behind a filled medal, per the "Challenge Complete" comp:
///
/// ```html
/// <div class="absolute inset-0 bg-accent-ochre opacity-20 blur-3xl rounded-full scale-150">
/// <div class="relative w-32 h-32 rounded-full border-4 border-primary bg-surface shadow-lg">
///   <div class="w-24 h-24 rounded-full border-4 border-secondary bg-primary">
///     <span class="material-symbols-outlined text-text-button text-5xl" FILL 1>
///       workspace_premium
/// ```
///
/// The emblem keeps one fixed palette in both themes: the comp resolves
/// `primary` to forest `#0F5233` and `secondary` to mint `#339C6B` even in
/// dark mode, rather than following the dark scheme's lighter roles, and the
/// medal is always crisp white. Only the ground between the two rings tracks
/// the theme, which `surfaceContainerLow` already does (cream / dark card).
class _CelebrationBadge extends StatelessWidget {
  const _CelebrationBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    return SizedBox(
      width: 168,
      height: 168,
      child: Center(
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surfaceContainerLow,
            border: Border.all(color: AppPalette.primary, width: 4),
            // `bg-accent-ochre opacity-20 blur-3xl scale-150` — a soft warm
            // halo. Drawn as a blurred shadow because a plain circle at this
            // radius read as a flat tan ring rather than a glow.
            boxShadow: [
              BoxShadow(
                color: appColors.warning.withValues(alpha: 0.2),
                blurRadius: 48,
                spreadRadius: 16,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.primary,
              border: Border.all(color: AppPalette.secondary, width: 4),
            ),
            alignment: Alignment.center,
            // The comp shows the filled medal whether or not the goal was
            // met — it has no second variant, and the old `trending_up`
            // fallback was invented here.
            child: const Icon(
              Icons.workspace_premium,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


/// One summary row: filled icon and label leading, figure trailing, with a
/// hairline under every row but the last (`border-b border-divider/50`).
class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: valueColor ?? scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// One week's bar: `W3` label, then a full-round track filled to [value].
class _WeekBar extends StatelessWidget {
  final String label;
  final double value;
  final bool isLast;

  const _WeekBar({
    required this.label,
    required this.value,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.brFull,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: scheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
