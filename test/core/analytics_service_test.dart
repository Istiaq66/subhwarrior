import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/analytics/analytics_service.dart';

void main() {
  tearDown(() => AnalyticsService.maybeInstance = null);

  group('FakeAnalyticsService', () {
    test('records events with parameters in order', () async {
      final fake = FakeAnalyticsService();

      await fake.logEvent(AnalyticsEvents.challengeStarted);
      await fake.logEvent(AnalyticsEvents.dayLogged, {'qualifying': 'true'});

      expect(fake.events, hasLength(2));
      expect(fake.events[0].name, 'challenge_started');
      expect(fake.events[0].parameters, isNull);
      expect(fake.events[1].name, 'day_logged');
      expect(fake.events[1].parameters, {'qualifying': 'true'});
    });
  });

  group('AnalyticsEvents', () {
    test('names match the growth-plan spec exactly', () {
      expect(AnalyticsEvents.challengeStarted, 'challenge_started');
      expect(AnalyticsEvents.dayLogged, 'day_logged');
      expect(AnalyticsEvents.streakMilestone, 'streak_milestone');
      expect(AnalyticsEvents.shareCardSent, 'share_card_sent');
      expect(AnalyticsEvents.inviteSent, 'invite_sent');
      expect(AnalyticsEvents.inviteAccepted, 'invite_accepted');
      expect(AnalyticsEvents.friendAdded, 'friend_added');
      expect(AnalyticsEvents.notificationOpened, 'notification_opened');
    });
  });

  group('AnalyticsService.maybeInstance', () {
    test('is null until set, then returns the set instance', () {
      expect(AnalyticsService.maybeInstance, isNull);
      final fake = FakeAnalyticsService();
      AnalyticsService.maybeInstance = fake;
      expect(AnalyticsService.maybeInstance, same(fake));
    });
  });
}
