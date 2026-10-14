import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/features/auth/data/account_deletion.dart';
import 'package:subh_warrior/features/challenge/data/challenge_data.dart';
import 'package:subh_warrior/features/challenge/data/challenge_local_data_source.dart';

void main() {
  group('deleteAccount', () {
    late List<String> calls;

    Future<void> run({String? failAt}) => deleteAccount(
          reauthenticate: () async => _step(calls, 'reauthenticate', failAt),
          deleteUserData: () async => _step(calls, 'deleteUserData', failAt),
          cleanUpDevice: () async => _step(calls, 'cleanUpDevice', failAt),
          deleteAuthUser: () async => _step(calls, 'deleteAuthUser', failAt),
        );

    setUp(() => calls = []);

    test('proves identity, erases data, cleans up, then deletes the account',
        () async {
      await run();

      expect(calls, [
        'reauthenticate',
        'deleteUserData',
        'cleanUpDevice',
        'deleteAuthUser',
      ]);
    });

    test('a failed reauthentication deletes nothing', () async {
      await expectLater(run(failAt: 'reauthenticate'), throwsStateError);

      expect(calls, ['reauthenticate']);
    });

    test('a failed server delete never removes the account', () async {
      // If the account went first, the rules would no longer let the data be
      // deleted and it would be stranded.
      await expectLater(run(failAt: 'deleteUserData'), throwsStateError);

      expect(calls, ['reauthenticate', 'deleteUserData']);
      expect(calls, isNot(contains('deleteAuthUser')));
    });

    test('can be retried after the account delete itself fails', () async {
      await expectLater(run(failAt: 'deleteAuthUser'), throwsStateError);
      calls.clear();

      await run();

      expect(calls.last, 'deleteAuthUser');
    });
  });

  group('ChallengeLocalDataSource.clear', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        // Legacy, un-namespaced copy left behind by the migration.
        'userName': 'aisha',
        'userLatitude': 23.8,
        '__challenge_ns_migrated_v1__': true,
        // Another account on the same device, and app-wide settings.
        'other:userName': 'bilal',
        'themeMode': 'dark',
        'appLocale': 'ar',
      });
      prefs = await SharedPreferences.getInstance();
      await ChallengeLocalDataSource(prefs, uid: 'u1').save(
        ChallengeData(
          userName: 'aisha',
          userLocation: 'Dhaka',
          userLatitude: 23.8,
          userLongitude: 90.4,
          hasLocation: true,
        ),
      );
    });

    test('removes this user and the legacy copy, and nothing else', () async {
      await ChallengeLocalDataSource(prefs, uid: 'u1').clear();

      expect(prefs.getKeys().where((k) => k.startsWith('u1:')), isEmpty);
      expect(prefs.containsKey('userName'), isFalse);
      expect(prefs.containsKey('userLatitude'), isFalse);

      expect(prefs.getString('other:userName'), 'bilal');
      expect(prefs.getString('themeMode'), 'dark');
      expect(prefs.getString('appLocale'), 'ar');
    });

    test('keeps the migration marker so cleared keys are not copied back',
        () async {
      await ChallengeLocalDataSource(prefs, uid: 'u1').clear();

      expect(prefs.getBool('__challenge_ns_migrated_v1__'), isTrue);
    });

    test('leaves a cleared profile empty when loaded', () async {
      final source = ChallengeLocalDataSource(prefs, uid: 'u1');
      await source.clear();

      final data = source.load();
      expect(data.userName, isEmpty);
      expect(data.hasLocation, isFalse);
      expect(data.userLatitude, 0);
    });
  });
}

/// Records [name], then fails if it is the step under test.
void _step(List<String> calls, String name, String? failAt) {
  calls.add(name);
  if (name == failAt) throw StateError('$name failed');
}
