import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';
import 'package:subh_warrior/features/home/presentation/widgets/weekly_progress_card.dart';

void main() {
  // Regression: the seven day chips were a fixed 40dp each. Inside the card's
  // 24dp padding that exactly filled the row on a 360dp phone — chips edge to
  // edge with no gap — and overflowed on anything narrower.
  group('WeeklyProgressCard day chips', () {
    DayLog qualifyingLog(DateTime date) => DayLog(
          date: date,
          prayedFajrOnTime: true,
          minutesWorked: 30,
          workDescription: 'work',
          workType: WorkType.deepWork,
          isQualifying: true,
          loggedAt: date,
        );

    Future<void> pumpAtWidth(WidgetTester tester, double width) async {
      final today = DateTime.now();
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: WeeklyProgressCard(dayLogs: [qualifyingLog(today)]),
            ),
          ),
        ),
      ));
    }

    for (final width in [320.0, 360.0, 411.0]) {
      testWidgets('lay out without overflow at ${width.toInt()}dp',
          (tester) async {
        await pumpAtWidth(tester, width);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('shrink below 40dp on a narrow screen but keep a gap',
        (tester) async {
      await pumpAtWidth(tester, 320);

      // The check glyph marks the one qualifying day, so its enclosing circle
      // is the chip we can measure.
      final circle = tester.getSize(
        find.ancestor(
          of: find.byIcon(Icons.check),
          matching: find.byType(Container),
        ).first,
      );

      expect(circle.width, lessThan(40));
      expect(circle.width, greaterThanOrEqualTo(24));
      // Seven chips plus six gaps must still leave the row unfilled.
      expect(circle.width * 7, lessThan(320 - 48));
    });

    testWidgets('stay at the full 40dp when there is room', (tester) async {
      await pumpAtWidth(tester, 480);

      final circle = tester.getSize(
        find.ancestor(
          of: find.byIcon(Icons.check),
          matching: find.byType(Container),
        ).first,
      );

      expect(circle.width, 40);
    });
  });
}
