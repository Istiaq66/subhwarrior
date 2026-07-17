import 'package:flutter/material.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';

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

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.format_quote,
              size: 32,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
