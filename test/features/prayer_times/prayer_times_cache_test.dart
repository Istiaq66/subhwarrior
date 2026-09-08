import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subh_warrior/core/utils/date_time_utils.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_local_data_source.dart';
import 'package:subh_warrior/features/prayer_times/domain/cached_prayer_times.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_times.dart';
import 'package:subh_warrior/features/prayer_times/presentation/prayer_times_controller.dart';

import 'prayer_times_test.dart' show FakePrayerTimesRepository;

/// Stale-while-revalidate startup: Home paints the last valid times on its
/// first frame, and the network refresh runs behind them. These tests pin the
/// two things that make showing a cache safe — it must be today's, and it must
/// be for this place.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const today = PrayerTimes(
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
  const tomorrow = PrayerTimes(
    fajr: '05:01',
    sunrise: '06:01',
    dhuhr: '12:01',
    asr: '15:01',
    sunset: '18:01',
    maghrib: '18:06',
    isha: '19:31',
    imsak: '04:51',
    midnight: '00:01',
  );

  CachedPrayerTimes cacheFor(
    DateTime date, {
    double latitude = 23.8,
    double longitude = 90.4,
  }) =>
      CachedPrayerTimes(
        today: today,
        tomorrow: tomorrow,
        date: date,
        latitude: latitude,
        longitude: longitude,
      );

  group('PrayerTimesLocalDataSource cache', () {
    Future<PrayerTimesLocalDataSource> source() async {
      SharedPreferences.setMockInitialValues({});
      return PrayerTimesLocalDataSource(await SharedPreferences.getInstance());
    }

    test('round-trips times, date and coordinates', () async {
      final local = await source();
      final date = DateTime(2026, 9, 8);

      await local.saveCache(cacheFor(date, latitude: 23.81, longitude: 90.41));
      final read = local.loadCache();

      expect(read, isNotNull);
      expect(read!.today.fajr, '05:00');
      expect(read.tomorrow.fajr, '05:01');
      expect(read.today.midnight, '00:00');
      expect(read.date, date);
      expect(read.latitude, closeTo(23.81, 0.0001));
      expect(read.longitude, closeTo(90.41, 0.0001));
    });

    test('reads null when nothing was ever saved', () async {
      final local = await source();
      expect(local.loadCache(), isNull);
    });

    test('strips the time component off the stored date', () async {
      final local = await source();

      await local.saveCache(cacheFor(DateTime(2026, 9, 8, 17, 42)));

      expect(local.loadCache()!.date, DateTime(2026, 9, 8));
    });

    test('degrades to no-cache on an unreadable entry', () async {
      SharedPreferences.setMockInitialValues(
          {'flutter.prayer_times_cache': 'not json at all'});
      final local =
          PrayerTimesLocalDataSource(await SharedPreferences.getInstance());

      expect(local.loadCache(), isNull);
    });

    test('clearCache removes the entry', () async {
      final local = await source();
      await local.saveCache(cacheFor(DateTime(2026, 9, 8)));

      await local.clearCache();

      expect(local.loadCache(), isNull);
    });
  });

  group('CachedPrayerTimes validity', () {
    final now = DateTime(2026, 9, 8, 6, 30);

    test('is valid for the same calendar date and location', () {
      expect(
        cacheFor(DateTime(2026, 9, 8))
            .isValidFor(now: now, latitude: 23.8, longitude: 90.4),
        isTrue,
      );
    });

    test('is valid regardless of the time of day it was fetched', () {
      expect(
        cacheFor(DateTime(2026, 9, 8, 23, 59))
            .isValidFor(now: now, latitude: 23.8, longitude: 90.4),
        isTrue,
      );
    });

    test('is invalid once the calendar day has rolled over', () {
      expect(
        cacheFor(DateTime(2026, 9, 7))
            .isValidFor(now: now, latitude: 23.8, longitude: 90.4),
        isFalse,
      );
    });

    test('is invalid for a date in the future', () {
      expect(
        cacheFor(DateTime(2026, 9, 9))
            .isValidFor(now: now, latitude: 23.8, longitude: 90.4),
        isFalse,
      );
    });

    test('survives GPS jitter within tolerance', () {
      // A few metres of drift between launches must not throw the cache away.
      expect(
        cacheFor(DateTime(2026, 9, 8))
            .isValidFor(now: now, latitude: 23.8009, longitude: 90.3995),
        isTrue,
      );
    });

    test('is invalid once coordinates move meaningfully', () {
      expect(
        cacheFor(DateTime(2026, 9, 8))
            .isValidFor(now: now, latitude: 24.9, longitude: 91.8),
        isFalse,
      );
    });

    test('treats a drift just past the tolerance as elsewhere', () {
      const beyond = CachedPrayerTimes.coordinateTolerance * 2;
      expect(
        cacheFor(DateTime(2026, 9, 8))
            .isValidFor(now: now, latitude: 23.8 + beyond, longitude: 90.4),
        isFalse,
      );
    });
  });

  group('PrayerTimeProvider startup', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('first launch starts with no times and no cached source', () {
      final repo = FakePrayerTimesRepository();

      final controller = PrayerTimeProvider(repo);

      expect(controller.hasTimes, isFalse);
      expect(controller.todayPrayerTimes, isNull);
      expect(controller.source, PrayerTimesSource.none);
      expect(controller.isLoading, isFalse);
    });

    test('hydrates from a same-day cache before any fetch', () {
      final repo = FakePrayerTimesRepository(
        cached: cacheFor(AppDateUtils.dateOnly(DateTime.now())),
      );

      final controller = PrayerTimeProvider(repo);

      expect(controller.hasTimes, isTrue);
      expect(controller.todayPrayerTimes?.fajr, '05:00');
      expect(controller.tomorrowPrayerTimes?.fajr, '05:01');
      expect(controller.source, PrayerTimesSource.cache);
      expect(repo.fetchCount, 0, reason: 'hydration must not hit the network');
    });

    test('ignores a cache from a previous day', () {
      final repo = FakePrayerTimesRepository(
        cached: cacheFor(
          AppDateUtils.dateOnly(DateTime.now()).subtract(
            const Duration(days: 1),
          ),
        ),
      );

      final controller = PrayerTimeProvider(repo);

      expect(controller.hasTimes, isFalse,
          reason: "yesterday's Fajr must never show as today's");
      expect(controller.source, PrayerTimesSource.none);
    });
  });

  group('PrayerTimeProvider revalidation', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    const freshTimes = PrayerTimes(
      fajr: '04:44',
      sunrise: '06:00',
      dhuhr: '12:00',
      asr: '15:00',
      sunset: '18:00',
      maghrib: '18:05',
      isha: '19:30',
      imsak: '04:30',
      midnight: '00:00',
    );

    test('fresh data replaces the cache and is persisted', () async {
      final repo = FakePrayerTimesRepository(
        result: freshTimes,
        cached: cacheFor(AppDateUtils.dateOnly(DateTime.now())),
      );
      final controller = PrayerTimeProvider(repo);
      expect(controller.todayPrayerTimes?.fajr, '05:00');

      await controller.fetchPrayerTimes(23.8, 90.4);

      expect(controller.todayPrayerTimes?.fajr, '04:44');
      expect(controller.source, PrayerTimesSource.network);
      expect(repo.savedCaches, hasLength(1));
      expect(repo.savedCaches.single.today.fajr, '04:44');
      expect(repo.savedCaches.single.latitude, 23.8);
      expect(repo.savedCaches.single.date.day, DateTime.now().day);
    });

    // `isLoading` is set synchronously before the first await, so reading it
    // off an un-awaited call catches the in-flight state. Listening for
    // notifications would not: `_notifyDeferred` posts a post-frame callback,
    // which never runs outside `testWidgets`.
    test('never shows a spinner while cached times are on screen', () async {
      final repo = FakePrayerTimesRepository(
        cached: cacheFor(AppDateUtils.dateOnly(DateTime.now())),
      );
      final controller = PrayerTimeProvider(repo);

      final inFlight = controller.fetchPrayerTimes(23.8, 90.4);

      expect(controller.isLoading, isFalse,
          reason: 'a revalidation must not swap real times for a spinner');
      expect(controller.todayPrayerTimes?.fajr, '05:00');
      await inFlight;
    });

    test('a failed refresh keeps cached times and raises no error', () async {
      final repo = FakePrayerTimesRepository(
        cached: cacheFor(AppDateUtils.dateOnly(DateTime.now())),
        fetchError: Exception('offline'),
      );
      final controller = PrayerTimeProvider(repo);

      await controller.fetchPrayerTimes(23.8, 90.4);

      expect(controller.todayPrayerTimes?.fajr, '05:00');
      expect(controller.hasTimes, isTrue);
      expect(controller.error, isEmpty);
      expect(repo.savedCaches, isEmpty,
          reason: 'a failed fetch must not overwrite a good cache');
    });

    test('a failed first fetch surfaces an error, having nothing to show',
        () async {
      final repo = FakePrayerTimesRepository(fetchError: Exception('offline'));
      final controller = PrayerTimeProvider(repo);

      await controller.fetchPrayerTimes(23.8, 90.4);

      expect(controller.hasTimes, isFalse);
      expect(controller.error, isNotEmpty);
    });

    test('drops cached times fetched for a different location', () async {
      final repo = FakePrayerTimesRepository(
        result: freshTimes,
        cached: cacheFor(AppDateUtils.dateOnly(DateTime.now())),
      );
      final controller = PrayerTimeProvider(repo);
      expect(controller.source, PrayerTimesSource.cache);

      // Moved far enough that the old times are for somewhere else: they must
      // not linger on screen while the new location is fetched.
      final inFlight = controller.fetchPrayerTimes(51.5, -0.12);

      expect(controller.hasTimes, isFalse,
          reason: "another place's times must not stay on screen");
      expect(controller.isLoading, isTrue);
      await inFlight;

      expect(controller.todayPrayerTimes?.fajr, '04:44');
      expect(repo.savedCaches.single.latitude, 51.5);
    });

    test('keeps cached times when coordinates only jittered', () async {
      final repo = FakePrayerTimesRepository(
        result: freshTimes,
        cached: cacheFor(AppDateUtils.dateOnly(DateTime.now())),
      );
      final controller = PrayerTimeProvider(repo);

      final inFlight = controller.fetchPrayerTimes(23.8008, 90.4004);

      expect(controller.isLoading, isFalse);
      expect(controller.todayPrayerTimes?.fajr, '05:00',
          reason: 'jitter is the same place — keep showing the cache');
      await inFlight;

      expect(controller.todayPrayerTimes?.fajr, '04:44');
    });
  });

  group('PrayerTimeProvider.loadForProfile', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('does nothing when the profile has no location', () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      await controller.loadForProfile(
        hasLocation: false,
        hasUsableCoordinates: false,
        latitude: 0,
        longitude: 0,
      );

      expect(repo.fetchCount, 0);
    });

    test('prefers real coordinates when the profile has them', () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      await controller.loadForProfile(
        hasLocation: true,
        hasUsableCoordinates: true,
        latitude: 23.8,
        longitude: 90.4,
        cityCountry: (city: 'Dhaka', country: 'Bangladesh'),
      );

      expect(repo.savedCaches.single.latitude, 23.8);
    });

    test('falls back to a city lookup, cached against the 0,0 sentinel',
        () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      await controller.loadForProfile(
        hasLocation: true,
        hasUsableCoordinates: false,
        latitude: 0,
        longitude: 0,
        cityCountry: (city: 'Dhaka', country: 'Bangladesh'),
      );

      expect(controller.hasTimes, isTrue);
      expect(repo.savedCaches.single.latitude, 0.0);
      expect(repo.savedCaches.single.longitude, 0.0);
    });

    test('startup never reaches for device location', () async {
      final repo = FakePrayerTimesRepository();
      final controller = PrayerTimeProvider(repo);

      // Bare name only: the device-location rung is the sole remaining option,
      // and boot must not take it — a GPS prompt over the splash has no
      // context.
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
      expect(repo.savedCaches.single.latitude, 23.8);
    });
  });
}
