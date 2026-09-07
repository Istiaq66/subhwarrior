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

    // Regression for A1: the splash used to self-navigate on a 2s timer, which
    // could fire after disposal and throw "Navigator in disposed context". It
    // is now a passive screen that `main.dart`'s boot gate swaps out, so
    // disposing it early — and letting time pass — must stay silent.
    testWidgets('is inert after disposal', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpWidget(buildApp(home: const SizedBox()));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('offers a retry when boot fails', (tester) async {
      var retried = false;
      await tester.pumpWidget(buildApp(
        home: SplashScreen(bootFailed: true, onRetry: () => retried = true),
      ));
      // Matched by subtype, not `find.byType`: `OutlinedButton.icon` builds a
      // private `_OutlinedButtonWithIcon` subclass on some Flutter versions
      // (3.35, which CI pins) and a plain `OutlinedButton` on others, and
      // `find.byType` only matches the exact runtime type.
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is OutlinedButton));
      expect(retried, isTrue);
    });
  });
}
