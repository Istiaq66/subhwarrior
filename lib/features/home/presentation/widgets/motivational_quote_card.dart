import 'package:flutter/material.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';

/// Daily-rotating motivational quote card. The quote is chosen by day-of-month
/// so it is stable within a day.
class MotivationalQuoteCard extends StatelessWidget {
  const MotivationalQuoteCard({super.key});

  static List<String> _quotes(AppLocalizations l10n) => [
        l10n.quote1,
        l10n.quote2,
        l10n.quote3,
        l10n.quote4,
        l10n.quote5,
        l10n.quote6,
        l10n.quote7,
        l10n.quote8,
        l10n.quote9,
        l10n.quote10,
      ];

  @override
  Widget build(BuildContext context) {
    // Rotate daily through the whole list (day-of-year, not day-of-month, so
    // every quote is shown and the cycle doesn't reset each month).
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final quotes = _quotes(AppLocalizations.of(context)!);
    final quote = quotes[dayOfYear % quotes.length];

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Comp: cream card, `p-8`, centred italic `text-lg` primary quote, with a
    // 32px `primary/20` quote glyph pinned to the leading top corner. The card
    // colour comes from the theme, so it is cream here rather than the mint
    // tint this card used before.
    return Card(
      child: Stack(
        children: [
          PositionedDirectional(
            top: AppSpacing.md,
            start: AppSpacing.md,
            child: Icon(
              Icons.format_quote,
              size: 32,
              color: scheme.primary.withValues(alpha: 0.20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
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
