import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/share/presentation/streak_share_card.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renders streak, qualifying days and week', (tester) async {
    await tester.pumpWidget(_wrap(const StreakShareCard(
      currentStreak: 7,
      totalQualifyingDays: 5,
      currentWeek: 2,
    )));

    expect(find.text('7'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Week 2 of 4'), findsOneWidget);
    expect(find.text('Subh Warrior'), findsOneWidget);
  });

  testWidgets('localizes digits in Bengali', (tester) async {
    await tester.pumpWidget(_wrap(
      const StreakShareCard(
        currentStreak: 7,
        totalQualifyingDays: 5,
        currentWeek: 2,
      ),
      locale: const Locale('bn'),
    ));

    expect(find.text('৭'), findsOneWidget); // Bengali 7
  });
}
