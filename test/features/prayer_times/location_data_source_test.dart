import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:subh_warrior/features/prayer_times/data/location_data_source.dart';

/// Stands in for the platform plugin. Extending (rather than implementing)
/// [GeolocatorPlatform] passes its token check.
class _FakeGeolocator extends GeolocatorPlatform {
  _FakeGeolocator({this.current, this.lastKnown});

  /// Answer for a fresh fix; null simulates one that never arrives.
  final Position? current;
  final Position? lastKnown;
  LocationSettings? requested;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    requested = locationSettings;
    final fix = current;
    // What the plugin does when `timeLimit` passes with no fix.
    if (fix == null) throw TimeoutException('no fix');
    return fix;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async =>
      lastKnown;
}

Position _at(double latitude, double longitude) => Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime(2026, 10, 12),
      accuracy: 50,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  group('LocationDataSource.deviceFix', () {
    test('asks for a time-limited, medium-accuracy fix', () async {
      final fake = _FakeGeolocator(current: _at(23.8, 90.4));
      GeolocatorPlatform.instance = fake;

      final fix = await LocationDataSource.deviceFix();

      expect(fix, (latitude: 23.8, longitude: 90.4));
      expect(fake.requested?.timeLimit, LocationDataSource.fixTimeLimit);
      expect(fake.requested?.accuracy, LocationAccuracy.medium);
    });

    test('settles for the last known position when no fix arrives', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(lastKnown: _at(23.7, 90.3));

      expect(await LocationDataSource.deviceFix(),
          (latitude: 23.7, longitude: 90.3));
    });

    test('times out instead of hanging when there is no position at all',
        () async {
      GeolocatorPlatform.instance = _FakeGeolocator();

      await expectLater(
          LocationDataSource.deviceFix(), throwsA(isA<TimeoutException>()));
    });
  });
}
