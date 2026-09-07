import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/screens/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    // `AppTheme` is what registers the `AppColorsX` extension that screens
    // read via `context.appColors`, and `main.dart` always supplies it. Without
    // it here the harness builds a screen in a state the app never produces.
    Widget buildApp({Widget home = const SplashScreen()}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: home,
      );
    }

    testWidgets('renders branding text', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Subh Warrior'), findsOneWidget);
    });

    // Regression for A1: navigating away (disposing) before the 2s timer
    // fires must not throw "Navigator in disposed context".
    testWidgets('cancels navigation timer on dispose', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpWidget(buildApp(home: const SizedBox()));
      // Advance past the splash duration; the cancelled timer must be a no-op.
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });
  });
}
