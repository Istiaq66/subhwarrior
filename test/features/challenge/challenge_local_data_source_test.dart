import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/features/challenge/data/challenge_data.dart';
import 'package:subh_warrior/features/challenge/data/challenge_local_data_source.dart';
import 'package:subh_warrior/features/challenge/domain/day_log.dart';
import 'package:subh_warrior/features/challenge/domain/work_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('ChallengeLocalDataSource round-trip', () {
    test('save then load restores all fields under a uid namespace', () async {
      final prefs = await prefsWith({});
      final ds = ChallengeLocalDataSource(prefs, uid: 'uid1');

      final data = ChallengeData(
        challengeStartDate: DateTime(2026, 7, 6),
        isChallengeActive: true,
        currentStreak: 5,
        totalQualifyingDays: 9,
        currentWeek: 3,
        userName: 'aisha',
        userLocation: 'Dhaka, Bangladesh',
        userLatitude: 23.8103,
        userLongitude: 90.4125,
        hasLocation: true,
        notificationsEnabled: false,
        fajrReminder: false,
        loggingReminder: false,
        fajrReminderMinutes: 20,
        dayLogs: [
          DayLog(
            date: DateTime(2026, 7, 2),
            prayedFajrOnTime: true,
            prayedAtMasjid: false,
            minutesWorked: 75,
            workDescription: 'Deep work',
            workType: WorkType.deepWork,
            isQualifying: true,
            loggedAt: DateTime(2026, 7, 2, 7, 30),
          ),
        ],
      );

      await ds.save(data);
      final loaded = ds.load();

      expect(loaded.challengeStartDate, DateTime(2026, 7, 6));
      expect(loaded.isChallengeActive, isTrue);
      expect(loaded.currentStreak, 5);
      expect(loaded.totalQualifyingDays, 9);
      expect(loaded.currentWeek, 3);
      expect(loaded.userName, 'aisha');
      expect(loaded.userLocation, 'Dhaka, Bangladesh');
      expect(loaded.userLatitude, 23.8103);
      expect(loaded.userLongitude, 90.4125);
      expect(loaded.hasLocation, isTrue);
      expect(loaded.notificationsEnabled, isFalse);
      expect(loaded.fajrReminder, isFalse);
      expect(loaded.loggingReminder, isFalse);
      expect(loaded.fajrReminderMinutes, 20);
      expect(loaded.dayLogs, hasLength(1));
      expect(loaded.dayLogs.single.minutesWorked, 75);
      expect(loaded.dayLogs.single.workType, WorkType.deepWork);
    });

    test('load returns defaults on an empty store', () async {
      final prefs = await prefsWith({});
      final ds = ChallengeLocalDataSource(prefs, uid: 'uid1');

      final loaded = ds.load();

      expect(loaded.challengeStartDate, isNull);
      expect(loaded.isChallengeActive, isFalse);
      expect(loaded.currentStreak, 0);
      expect(loaded.currentWeek, 1);
      expect(loaded.dayLogs, isEmpty);
    });

    test('different uids do not read each other\'s state', () async {
      final prefs = await prefsWith({});
      final ds1 = ChallengeLocalDataSource(prefs, uid: 'uid1');
      final ds2 = ChallengeLocalDataSource(prefs, uid: 'uid2');

      await ds1.save(ChallengeData(userName: 'aisha'));

      expect(ds2.load().userName, isEmpty);
      expect(ds1.load().userName, 'aisha');
    });
  });

  group('migrateLegacyIfNeeded', () {
    test('copies legacy un-namespaced keys to the uid namespace', () async {
      final prefs = await prefsWith({
        'userName': 'legacy-user',
        'currentStreak': 4,
        'isChallengeActive': true,
        'userLatitude': 1.5,
      });

      await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, 'uid1');

      final loaded = ChallengeLocalDataSource(prefs, uid: 'uid1').load();
      expect(loaded.userName, 'legacy-user');
      expect(loaded.currentStreak, 4);
      expect(loaded.isChallengeActive, isTrue);
      expect(loaded.userLatitude, 1.5);
    });

    test('does not overwrite existing namespaced values', () async {
      final prefs = await prefsWith({
        'userName': 'legacy-user',
        'uid1:userName': 'already-migrated',
      });

      await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, 'uid1');

      expect(prefs.getString('uid1:userName'), 'already-migrated');
    });

    test('runs at most once per device', () async {
      final prefs = await prefsWith({'userName': 'first'});

      await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, 'uid1');
      await prefs.setString('userName', 'second');
      await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, 'uid2');

      expect(prefs.getString('uid2:userName'), isNull);
    });

    test('is a no-op for an empty uid', () async {
      final prefs = await prefsWith({'userName': 'legacy-user'});

      await ChallengeLocalDataSource.migrateLegacyIfNeeded(prefs, '');

      expect(prefs.getKeys(), {'userName'});
    });
  });
}
