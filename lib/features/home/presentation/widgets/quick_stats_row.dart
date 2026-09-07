import 'package:flutter/material.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';

/// Three stat tiles: the current streak as the hero figure, then qualifying
/// days and days remaining.
///
/// The comps show a "best streak" tile here. Nothing in the data layer tracks a
/// best streak, so this keeps days-remaining — real information the app already
/// computes — in that slot.
class QuickStatsRow extends StatelessWidget {
  final int currentStreak;
  final int totalQualifyingDays;
  final int daysRemaining;
  final VoidCallback? onShare;

  const QuickStatsRow({
    super.key,
    required this.currentStreak,
    required this.totalQualifyingDays,
    required this.daysRemaining,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      // Stretch, so the streak tile spans the full width like the comp's
      // `col-span-2` cell instead of shrink-wrapping its content.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StreakTile(currentStreak: currentStreak, onShare: onShare),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.verified,
                  value: '$totalQualifyingDays',
                  label: l10n.streakCardQualifyingDays,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_today,
                  value: '$daysRemaining',
                  label: l10n.quickStatsDaysLeft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakTile extends StatelessWidget {
  final int currentStreak;
  final VoidCallback? onShare;

  const _StreakTile({required this.currentStreak, this.onShare});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Card(
      child: Stack(
        children: [
          // Oversized flame watermark, clipped by the card's own clipBehavior.
          PositionedDirectional(
            top: -16,
            end: -16,
            child: Icon(
              Icons.local_fire_department,
              size: 120,
              color: appColors.warning.withValues(alpha: 0.10),
            ),
          ),
          // `width: infinity` because a non-positioned Stack child is given
          // loose constraints: without it the column shrink-wraps its text and
          // the Stack parks it at the top-start corner instead of centring it.
          SizedBox(
            width: double.infinity,
            child: Padding(
              // Extra side insets keep the centred label clear of the share
              // button pinned in the corner.
              padding: const EdgeInsetsDirectional.fromSTEB(48, 20, 48, 20),
              child: Column(
              children: [
                Text(
                  currentStreak == 1
                      ? l10n.streakCardDayStreak
                      : l10n.streakCardDaysStreak,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                // The gradient paints the glyphs themselves; ShaderMask needs a
                // solid source colour to multiply against, hence white here.
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  // `createShader` resolves the directional begin/end itself,
                  // so it needs the ambient TextDirection handed to it — the
                  // gradient has no BuildContext of its own. Without it this
                  // throws "No TextDirection found" during paint and the
                  // shader comes back null, leaving the numeral unpainted.
                  shaderCallback: (bounds) => LinearGradient(
                    colors: appColors.streakGradient,
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ).createShader(
                    bounds,
                    textDirection: Directionality.of(context),
                  ),
                  child: Text(
                    '$currentStreak',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
          if (onShare != null)
            PositionedDirectional(
              top: 4,
              end: 4,
              child: IconButton(
                icon: const Icon(Icons.share, size: 20),
                color: theme.colorScheme.primary,
                tooltip: l10n.a11yShareStreak,
                onPressed: onShare,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
