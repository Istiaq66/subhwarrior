import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/screens/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('renders branding text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.text('Subh Warrior'), findsOneWidget);
    });

    // Regression for A1: navigating away (disposing) before the 2s timer
    // fires must not throw "Navigator in disposed context".
    testWidgets('cancels navigation timer on dispose', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      // Advance past the splash duration; the cancelled timer must be a no-op.
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });
  });
}
