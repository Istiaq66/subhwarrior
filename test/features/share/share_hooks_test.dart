import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/widgets/streak_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('streak card shows share button when onShare given',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(StreakCard(
      currentStreak: 3,
      totalDays: 2,
      onShare: () => tapped = true,
    )));

    final shareButton = find.byIcon(Icons.share);
    expect(shareButton, findsOneWidget);
    await tester.tap(shareButton);
    expect(tapped, isTrue);
  });

  testWidgets('streak card hides share button when onShare null',
      (tester) async {
    await tester.pumpWidget(_wrap(const StreakCard(
      currentStreak: 3,
      totalDays: 2,
    )));

    expect(find.byIcon(Icons.share), findsNothing);
  });

  testWidgets('streak card hides share button at zero streak', (tester) async {
    await tester.pumpWidget(_wrap(StreakCard(
      currentStreak: 0,
      totalDays: 0,
      onShare: () {},
    )));

    expect(find.byIcon(Icons.share), findsNothing);
  });
}
