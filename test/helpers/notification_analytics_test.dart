import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';
import 'package:subh_warrior/helpers/notification_service.dart';

void main() {
  tearDown(() => AnalyticsService.maybeInstance = null);

  test('handleNotificationTap logs notification_opened with payload', () {
    final fake = FakeAnalyticsService();
    AnalyticsService.maybeInstance = fake;

    NotificationService.handleNotificationTap('fajr_reminder');

    final event = fake.events.single;
    expect(event.name, 'notification_opened');
    expect(event.parameters, {'payload': 'fajr_reminder'});
  });

  test('handleNotificationTap is safe with no analytics and null payload', () {
    expect(
        () => NotificationService.handleNotificationTap(null), returnsNormally);
  });
}
