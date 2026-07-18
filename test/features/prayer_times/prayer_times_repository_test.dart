import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/features/prayer_times/data/location_data_source.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_local_data_source.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_remote_data_source.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_repository.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_settings.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_times.dart';

class _MockRemote extends Mock implements PrayerTimesRemoteDataSource {}

class _MockLocal extends Mock implements PrayerTimesLocalDataSource {}

class _MockLocation extends Mock implements LocationDataSource {}

const _times = PrayerTimes(
  fajr: '04:10',
  sunrise: '05:30',
  dhuhr: '12:05',
  asr: '16:40',
  sunset: '18:45',
  maghrib: '18:45',
  isha: '20:05',
  imsak: '04:00',
  midnight: '00:05',
);

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockLocation location;
  late PrayerTimesRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    location = _MockLocation();
    repository = PrayerTimesRepositoryImpl(remote, local, location);
  });

  group('PrayerTimesRepositoryImpl', () {
    test('fetchByCoordinates forwards method and derived school', () async {
      when(() => remote.fetchByCoordinates(
            date: any(named: 'date'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            method: any(named: 'method'),
            school: any(named: 'school'),
          )).thenAnswer((_) async => _times);

      const settings =
          PrayerSettings(calculationMethod: 3, useHanafiMethod: true);
      final result = await repository.fetchByCoordinates(
          DateTime(2026, 7, 18), 23.8, 90.4, settings);

      expect(result, same(_times));
      verify(() => remote.fetchByCoordinates(
            date: DateTime(2026, 7, 18),
            latitude: 23.8,
            longitude: 90.4,
            method: 3,
            school: 1, // Hanafi
          )).called(1);
    });

    test('fetchByCity forwards school 0 for the standard juristic method',
        () async {
      when(() => remote.fetchByCity(
            date: any(named: 'date'),
            city: any(named: 'city'),
            country: any(named: 'country'),
            method: any(named: 'method'),
            school: any(named: 'school'),
          )).thenAnswer((_) async => _times);

      const settings = PrayerSettings(calculationMethod: 5);
      await repository.fetchByCity(
          DateTime(2026, 7, 18), 'Dhaka', 'Bangladesh', settings);

      verify(() => remote.fetchByCity(
            date: DateTime(2026, 7, 18),
            city: 'Dhaka',
            country: 'Bangladesh',
            method: 5,
            school: 0,
          )).called(1);
    });

    test('currentCoordinates delegates to the location data source', () async {
      when(() => location.currentPosition())
          .thenAnswer((_) async => (latitude: 1.0, longitude: 2.0));

      final coords = await repository.currentCoordinates();

      expect(coords.latitude, 1.0);
      expect(coords.longitude, 2.0);
    });

    test('settings load/save delegate to the local data source', () async {
      const settings = PrayerSettings(use24HourFormat: true);
      when(() => local.load()).thenReturn(settings);
      when(() => local.save(settings)).thenAnswer((_) async {});

      expect(repository.loadSettings(), same(settings));
      await repository.saveSettings(settings);
      verify(() => local.save(settings)).called(1);
    });
  });

  group('PrayerTimesLocalDataSource', () {
    test('round-trips settings through SharedPreferences', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = PrayerTimesLocalDataSource(prefs);

      expect(
          ds.load().calculationMethod, PrayerSettings.defaultCalculationMethod);

      await ds.save(const PrayerSettings(
        calculationMethod: 4,
        useHanafiMethod: true,
        use24HourFormat: true,
      ));

      final loaded = ds.load();
      expect(loaded.calculationMethod, 4);
      expect(loaded.useHanafiMethod, isTrue);
      expect(loaded.use24HourFormat, isTrue);
    });
  });
}
