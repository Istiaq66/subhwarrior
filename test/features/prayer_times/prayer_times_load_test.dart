import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';

import 'prayer_times_test.dart' show FakePrayerTimesRepository;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PrayerTimeProvider.loadForProfile', () {
    test('does nothing when the profile has no location', () async {
      final repo = FakePrayerTimesRepository();

      await PrayerTimeProvider(repo).loadForProfile(
        hasLocation: false,
        hasUsableCoordinates: false,
        latitude: 0,
        longitude: 0,
      );

      expect(repo.fetchCount, 0);
    });

    test('uses the profile coordinates when it has them', () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      await controller.loadForProfile(
        hasLocation: true,
        hasUsableCoordinates: true,
        latitude: 21.4,
        longitude: 39.8,
      );

      expect(controller.hasTimes, isTrue);
      expect(repo.lastLatitude, 21.4);
    });

    test('startup never reaches for device location', () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      // A GPS prompt over the splash screen has no context.
      await controller.loadForProfile(
        hasLocation: true,
        hasUsableCoordinates: false,
        latitude: 0,
        longitude: 0,
        allowDeviceLocation: false,
      );

      expect(repo.fetchCount, 0);
      expect(controller.hasTimes, isFalse);
    });

    test('Home may reach for device location', () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      await controller.loadForProfile(
        hasLocation: true,
        hasUsableCoordinates: false,
        latitude: 0,
        longitude: 0,
      );

      // FakePrayerTimesRepository.currentCoordinates answers 23.8/90.4.
      expect(controller.hasTimes, isTrue);
      expect(repo.lastLatitude, 23.8);
    });
  });

  test('a failed calculation surfaces an error', () async {
    final repo = FakePrayerTimesRepository(fetchError: ArgumentError('bad'));
    final controller = PrayerTimeProvider(repo);

    await controller.fetchPrayerTimes(23.8, 90.4);

    expect(controller.hasTimes, isFalse);
    expect(controller.error, isNotEmpty);
  });
}
