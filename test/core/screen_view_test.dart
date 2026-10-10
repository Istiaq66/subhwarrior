import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/core/analytics/screen_view.dart';
import 'package:subh_warrior/core/crash/crash_reporting.dart';

void main() {
  late FakeAnalyticsService analytics;

  setUp(() {
    analytics = FakeAnalyticsService();
    AnalyticsService.maybeInstance = analytics;
  });

  tearDown(() => AnalyticsService.maybeInstance = null);

  testWidgets('ScreenView logs one screen_view when first shown',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: ScreenView(name: AnalyticsScreens.settings, child: SizedBox()),
    ));
    await tester.pump();

    expect(analytics.events, hasLength(1));
    expect(analytics.events.single.name, AnalyticsEvents.screenView);
    expect(analytics.events.single.parameters, {
      'screen_name': 'settings',
      'screen_class': 'settings',
    });
  });

  testWidgets('a keyed ScreenView logs again when the screen is swapped',
      (tester) async {
    Widget app(String name) => Directionality(
          textDirection: TextDirection.ltr,
          child: ScreenView(
              key: ValueKey(name), name: name, child: const SizedBox()),
        );

    await tester.pumpWidget(app(AnalyticsScreens.auth));
    await tester.pumpWidget(app(AnalyticsScreens.onboarding));

    expect(
      analytics.events.map((e) => e.parameters!['screen_name']),
      ['auth', 'onboarding'],
    );
  });

  test('logScreenView is a no-op before analytics exists', () {
    AnalyticsService.maybeInstance = null;
    expect(() => logScreenView('home'), returnsNormally);
  });

  test('CrashReporting is a safe no-op before init', () {
    expect(
      () => CrashReporting.recordNonFatal('x', StackTrace.current, 'test'),
      returnsNormally,
    );
  });
}
