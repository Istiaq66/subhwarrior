import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/features/prayer_times/data/location_data_source.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_calculator.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_local_data_source.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_repository.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_settings.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_times.dart';

class _MockCalculator extends Mock implements PrayerTimesCalculator {}

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
  late _MockCalculator calculator;
  late _MockLocal local;
  late _MockLocation location;
  late PrayerTimesRepositoryImpl repository;

  setUpAll(() => registerFallbackValue((latitude: 0.0, longitude: 0.0)));

  setUp(() {
    calculator = _MockCalculator();
    local = _MockLocal();
    location = _MockLocation();
    repository = PrayerTimesRepositoryImpl(calculator, local, location);
    when(() => calculator.calculate(
          date: any(named: 'date'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          method: any(named: 'method'),
          school: any(named: 'school'),
        )).thenReturn(_times);
  });

  group('PrayerTimesRepositoryImpl', () {
    test('fetchByCoordinates forwards method and derived school', () async {
      const settings =
          PrayerSettings(calculationMethod: 3, useHanafiMethod: true);
      final result = await repository.fetchByCoordinates(
          DateTime(2026, 7, 18), 23.8, 90.4, settings);

      expect(result, same(_times));
      verify(() => calculator.calculate(
            date: DateTime(2026, 7, 18),
            latitude: 23.8,
            longitude: 90.4,
            method: 3,
            school: 1, // Hanafi
          )).called(1);
    });

    test('fetchByCity calculates from remembered coordinates without geocoding',
        () async {
      when(() => local.loadCityCoordinates('Dhaka', 'Bangladesh'))
          .thenReturn((latitude: 23.8, longitude: 90.4));

      const settings = PrayerSettings(calculationMethod: 5);
      await repository.fetchByCity(
          DateTime(2026, 7, 18), 'Dhaka', 'Bangladesh', settings);

      verifyNever(() => location.cityCoordinates(any(), any()));
      verify(() => calculator.calculate(
            date: DateTime(2026, 7, 18),
            latitude: 23.8,
            longitude: 90.4,
            method: 5,
            school: 0,
          )).called(1);
    });

    test('fetchByCity geocodes an unknown city once and remembers it',
        () async {
      when(() => local.loadCityCoordinates(any(), any())).thenReturn(null);
      when(() => location.cityCoordinates('Dhaka', 'Bangladesh'))
          .thenAnswer((_) async => (latitude: 23.8, longitude: 90.4));
      when(() => local.saveCityCoordinates(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.fetchByCity(DateTime(2026, 7, 18), 'Dhaka',
          'Bangladesh', const PrayerSettings());

      verify(() => local.saveCityCoordinates(
          'Dhaka', 'Bangladesh', (latitude: 23.8, longitude: 90.4))).called(1);
      verify(() => calculator.calculate(
            date: any(named: 'date'),
            latitude: 23.8,
            longitude: 90.4,
            method: any(named: 'method'),
            school: any(named: 'school'),
          )).called(1);
    });

    test('fetchByCity surfaces a failed geocode', () async {
      when(() => local.loadCityCoordinates(any(), any())).thenReturn(null);
      when(() => location.cityCoordinates(any(), any()))
          .thenThrow('offline');

      await expectLater(
        repository.fetchByCity(DateTime(2026, 7, 18), 'Dhaka', 'Bangladesh',
            const PrayerSettings()),
        throwsA('offline'),
      );
      verifyNever(() => local.saveCityCoordinates(any(), any(), any()));
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
        defaultsCountryCode: 'SA',
      ));

      final loaded = ds.load();
      expect(loaded.calculationMethod, 4);
      expect(loaded.useHanafiMethod, isTrue);
      expect(loaded.use24HourFormat, isTrue);
      expect(loaded.defaultsCountryCode, 'SA');
    });

    test('remembers geocoded coordinates for one city at a time', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = PrayerTimesLocalDataSource(prefs);

      expect(ds.loadCityCoordinates('Dhaka', 'Bangladesh'), isNull);

      await ds.saveCityCoordinates(
          'Dhaka', 'Bangladesh', (latitude: 23.8, longitude: 90.4));

      // Matching ignores case and surrounding whitespace.
      expect(ds.loadCityCoordinates(' dhaka ', 'BANGLADESH'),
          (latitude: 23.8, longitude: 90.4));
      expect(ds.loadCityCoordinates('Chittagong', 'Bangladesh'), isNull);
    });
  });
}
