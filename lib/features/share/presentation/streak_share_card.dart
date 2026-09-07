import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/l10n_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Fixed-size, self-contained visual for the shareable streak image.
/// No interactivity — designed to be wrapped in a [RepaintBoundary].
///
/// Laid out from the Stitch "Share your progress" comp: a square parchment
/// canvas with a single-corner ochre wash, an eyebrow label top-start, the
/// streak numeral filling the middle, and the wordmark paired with the
/// qualifying-day count along the bottom.
///
/// Note the surfaces are inverted relative to the sheet that hosts it — the
/// sheet is cream and this card is parchment — which is what makes the preview
/// read as a separate image rather than part of the sheet.
///
/// Works in both brightnesses: every colour comes from the theme, so the dark
/// variant is a near-black green card with light text.
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

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // `streak-wash`: one corner only, and mirrored in RTL so it stays
            // on the leading-away side like the comp's `rtl:-scale-x-100`.
            PositionedDirectional(
              top: -70,
              end: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      appColors.streakGradientStart.withValues(alpha: 0.30),
                      appColors.streakGradientStart.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.shareCardEyebrow.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.localizeNumber(currentStreak),
                          textAlign: TextAlign.center,
                          // `text-8xl` in the comp. Pinned rather than taken
                          // from the type scale because this is an exported
                          // social image, not app chrome — the numeral is
                          // meant to dominate at thumbnail size.
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: scheme.primary,
                            fontSize: 96,
                            height: 1.0,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        AppSpacing.vGapSm,
                        Text(
                          l10n.shareCardStreakLabel.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.4,
                          ),
                        ),
                        AppSpacing.vGapMd,
                        Text(
                          l10n.shareCardWeekLabel(currentWeek),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          // Brand text, so it keeps its own casing and is
                          // letterspaced instead of transformed.
                          l10n.shareCardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                      AppSpacing.hGapSm,
                      // Count and label are separate spans so the figure stays
                      // individually assertable in tests; visually this is the
                      // comp's single "12 qualifying days" line.
                      Text(
                        context.localizeNumber(totalQualifyingDays),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.shareCardQualifyingLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}