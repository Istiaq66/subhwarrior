import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/l10n_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Fixed-size, self-contained visual for the shareable streak image.
/// No interactivity — designed to be wrapped in a [RepaintBoundary].
///
/// Follows the comp's text-only composition: a square canvas with one soft
/// ochre wash in a single corner, the streak numeral dominating the centre,
/// and the wordmark in the bottom corner. The earlier version filled the whole
/// card with the ochre streak gradient and stacked a mosque icon, a flame and
/// four figures on top of it — the number is the message, so everything that
/// competed with it is gone. Nothing overlaps the digits.
///
/// Works in both brightnesses: the canvas, ink and wash all come from the
/// theme, so the dark variant is a near-black green card with light text.
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appColors = context.appColors;

    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Single-corner wash, confined so it never reaches the numeral.
          PositionedDirectional(
            top: -60,
            end: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    appColors.streakGradientStart.withValues(alpha: 0.28),
                    appColors.streakGradientStart.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  context.localizeNumber(currentStreak),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: scheme.primary,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                AppSpacing.vGapSm,
                Text(
                  l10n.shareCardStreakLabel.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    letterSpacing: 2,
                  ),
                ),
                AppSpacing.vGapMd,
                // The qualifying-day count is the second figure the card
                // exists to show — the number stays, not just its label.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      context.localizeNumber(totalQualifyingDays),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    AppSpacing.hGapXs,
                    Text(
                      l10n.shareCardQualifyingLabel,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                AppSpacing.vGapXs,
                Text(
                  l10n.shareCardWeekLabel(currentWeek),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const Spacer(),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    // Left in title case: the wordmark is brand text, so it is
                    // letterspaced rather than transformed.
                    l10n.shareCardTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
