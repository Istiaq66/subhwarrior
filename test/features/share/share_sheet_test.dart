import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/share/presentation/share_sheet.dart';

Widget _wrap(Widget child, {required AnalyticsService analytics}) {
  return Provider<AnalyticsService>.value(
    value: analytics,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

void main() {
  testWidgets('share button does not log share_card_sent when capture fails',
      (tester) async {
    final analytics = FakeAnalyticsService();

    await tester.pumpWidget(_wrap(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showShareSheet(
                context,
                currentStreak: 5,
                totalQualifyingDays: 3,
                currentWeek: 1,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      analytics: analytics,
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.share), findsOneWidget);

    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    // In the widget-test environment path_provider/share_plus channels are
    // unavailable, so shareBoundary either throws or returns false. Either
    // way, the success-only analytics event must not fire.
    expect(
      analytics.events.where((e) => e.name == AnalyticsEvents.shareCardSent),
      isEmpty,
    );
  });
}
