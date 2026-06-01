import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/prayer_times/data/location_data_source.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_repository.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_settings.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_times.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';

class FakePrayerTimesRepository implements PrayerTimesRepository {
  PrayerSettings settings;
  final PrayerTimes result;
  int saveCount = 0;
  PrayerSettings? lastSaved;

  FakePrayerTimesRepository({
    PrayerSettings? settings,
    PrayerTimes? result,
  })  : settings = settings ?? const PrayerSettings(),
        result = result ?? _fixed;

  static const _fixed = PrayerTimes(
    fajr: '05:00',
    sunrise: '06:00',
    dhuhr: '12:00',
    asr: '15:00',
    sunset: '18:00',
    maghrib: '18:05',
    isha: '19:30',
    imsak: '04:50',
    midnight: '00:00',
  );

  @override
  Future<PrayerTimes> fetchByCoordinates(
          DateTime date, double lat, double lon, PrayerSettings s) async =>
      result;

  @override
  Future<PrayerTimes> fetchByCity(
          DateTime date, String city, String country, PrayerSettings s) async =>
      result;

  @override
  Future<Coordinates> currentCoordinates() async =>
      (latitude: 23.8, longitude: 90.4);

  @override
  PrayerSettings loadSettings() => settings;

  @override
  Future<void> saveSettings(PrayerSettings s) async {
    settings = s;
    lastSaved = s;
    saveCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrayerTimes.fromJson', () {
    test('strips the Aladhan timezone suffix', () {
      final pt = PrayerTimes.fromJson({
        'Fajr': '05:30 (+06)',
        'Sunrise': '06:10 (+06)',
        'Dhuhr': '12:00 (+06)',
        'Asr': '15:30 (+06)',
        'Sunset': '18:00 (+06)',
        'Maghrib': '18:05 (+06)',
        'Isha': '19:45 (+06)',
        'Imsak': '05:20 (+06)',
        'Midnight': '00:00 (+06)',
      });
      expect(pt.fajr, '05:30');
      expect(pt.sunrise, '06:10');
      expect(pt.isha, '19:45');
    });

    test('falls back to 00:00 for missing keys', () {
      final pt = PrayerTimes.fromJson({});
      expect(pt.fajr, '00:00');
      expect(pt.midnight, '00:00');
    });
  });

  group('PrayerSettings', () {
    test('school derives from juristic method', () {
      expect(const PrayerSettings(useHanafiMethod: false).school, 0);
      expect(const PrayerSettings(useHanafiMethod: true).school, 1);
    });
  });

  group('PrayerTimeProvider', () {
    test('loads settings from the repository on construction', () {
      final repo = FakePrayerTimesRepository(
        settings:
            const PrayerSettings(calculationMethod: 3, useHanafiMethod: true),
      );
      final controller = PrayerTimeProvider(repo);
      expect(controller.calculationMethod, 3);
      expect(controller.useHanafiMethod, isTrue);
    });

    test('updateCalculationMethod persists and updates state', () {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      controller.updateCalculationMethod(3);

      expect(controller.calculationMethod, 3);
      expect(repo.lastSaved?.calculationMethod, 3);
    });

    test('updateJuristicMethod persists and updates state', () {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      controller.updateJuristicMethod(true);

      expect(controller.useHanafiMethod, isTrue);
      expect(repo.lastSaved?.useHanafiMethod, isTrue);
    });

    test('fetchPrayerTimes populates today and tomorrow', () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      await controller.fetchPrayerTimes(23.8, 90.4);

      expect(controller.todayPrayerTimes?.fajr, '05:00');
      expect(controller.tomorrowPrayerTimes?.fajr, '05:00');
      expect(controller.error, isEmpty);
      expect(controller.isLoading, isFalse);
    });
  });
}
