import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/features/challenge/data/challenge_data.dart';
import 'package:subh_warrior/features/challenge/data/challenge_local_data_source.dart';

/// The Fajr call rings over the lock screen, so it carries its own switch
/// rather than riding on the Fajr reminder — and it stays off until asked for.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ChallengeLocalDataSource> sourceWith(
      Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return ChallengeLocalDataSource(await SharedPreferences.getInstance(),
        uid: 'u1');
  }

  test('defaults to off, unlike the Fajr reminder', () {
    final data = ChallengeData();

    expect(data.fajrCall, isFalse);
    expect(data.fajrReminder, isTrue);
  });

  test('an existing install without the key keeps the call off', () async {
    final source = await sourceWith({'u1:fajr_reminder': true});

    final data = source.load();

    expect(data.fajrReminder, isTrue);
    expect(data.fajrCall, isFalse);
  });

  test('the choice survives a save/load round trip', () async {
    final source = await sourceWith({});

    await source.save(ChallengeData(fajrCall: true, fajrReminder: false));
    final data = source.load();

    expect(data.fajrCall, isTrue);
    expect(data.fajrReminder, isFalse);
  });

  test('the key is namespaced per user like the rest', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await ChallengeLocalDataSource(prefs, uid: 'u1')
        .save(ChallengeData(fajrCall: true));

    expect(prefs.getBool('u1:fajr_call'), isTrue);
    expect(ChallengeLocalDataSource(prefs, uid: 'u2').load().fajrCall, isFalse);
  });
}
