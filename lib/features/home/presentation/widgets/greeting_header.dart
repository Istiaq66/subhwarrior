import 'package:flutter/material.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';

/// Time-of-day greeting plus the user's name at the top of the dashboard.
class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({super.key, required this.userName});

  String _greetingFor(AppLocalizations l10n, int hour) {
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 17) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greetingFor(l10n, DateTime.now().hour),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          userName.isNotEmpty ? userName : l10n.homeGreetingFallbackName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
