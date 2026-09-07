import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/l10n/l10n_utils.dart';

/// Salam greeting with the user's name, and today's date in both calendars.
///
/// The comp greets with a salam rather than a time-of-day greeting, and pairs
/// the Gregorian weekday/date with the Hijri day and month —
/// "Monday, 7 September · 25 Safar". Both halves localize: the Gregorian side
/// through `intl`, the Hijri side through [LocalizedHijriX], which formats the
/// month name and digits for the active locale.
class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name =
        userName.isNotEmpty ? userName : l10n.homeGreetingFallbackName;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final gregorian = DateFormat.MMMMEEEEd(locale).format(now);
    final hijri = context.formatHijri(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comp sizes: greeting `text-3xl` (30) bold, `mb-1`; date `text-sm`
        // (14) medium. Both come straight from the text theme, which carries
        // the comp's scale — headlineMedium is 30 and bodyMedium is 14.
        Text(
          '${l10n.homeGreetingSalam}, $name',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$gregorian  ·  $hijri',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
