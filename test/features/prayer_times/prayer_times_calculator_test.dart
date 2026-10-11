import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/prayer_times/data/prayer_times_calculator.dart';
import 'package:subh_warrior/features/prayer_times/domain/prayer_times.dart';

/// Reference values below are the Aladhan API's answers
/// (`/v1/timings/<date>?latitude=…&longitude=…&method=…&school=…`), captured
/// when the app moved off it, so a regression shows up as drift from the
/// times users had. Fajr must match exactly; everything else may differ by
/// the minute of rounding the two implementations disagree on.

PrayerTimesCalculator _atOffset(int hours) => PrayerTimesCalculator(
    toLocal: (t) => t.toUtc().add(Duration(hours: hours)));

int _minutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

Matcher _within1(String expected) => predicate<String>(
    (actual) => (_minutes(actual) - _minutes(expected)).abs() <= 1,
    'within a minute of $expected');

void _expectAladhan(PrayerTimes actual, Map<String, String> expected) {
  expect(actual.fajr, expected['fajr'], reason: 'fajr');
  expect(actual.imsak, expected['imsak'], reason: 'imsak');
  expect(actual.sunrise, _within1(expected['sunrise']!), reason: 'sunrise');
  expect(actual.dhuhr, _within1(expected['dhuhr']!), reason: 'dhuhr');
  expect(actual.asr, _within1(expected['asr']!), reason: 'asr');
  expect(actual.maghrib, _within1(expected['maghrib']!), reason: 'maghrib');
  expect(actual.sunset, _within1(expected['sunset']!), reason: 'sunset');
  expect(actual.isha, _within1(expected['isha']!), reason: 'isha');
  expect(actual.midnight, _within1(expected['midnight']!), reason: 'midnight');
}

void main() {
  group('PrayerTimesCalculator matches Aladhan', () {
    // Dhaka, 15 Jan 2026, UTC+6.
    const dhakaLat = 23.8103;
    const dhakaLon = 90.4125;
    final dhakaDay = DateTime(2026, 1, 15);
    const dhakaCommon = {
      'sunrise': '06:43',
      'dhuhr': '12:08',
      'sunset': '17:33',
      'maghrib': '17:33',
      'midnight': '00:08',
    };
    const dhaka = <int, Map<String, String>>{
      1: {'fajr': '05:23', 'imsak': '05:13', 'isha': '18:52'},
      2: {'fajr': '05:37', 'imsak': '05:27', 'isha': '18:38'},
      3: {'fajr': '05:23', 'imsak': '05:13', 'isha': '18:47'},
      4: {'fajr': '05:21', 'imsak': '05:11', 'isha': '19:03'},
      5: {'fajr': '05:17', 'imsak': '05:07', 'isha': '18:50'},
      15: {'fajr': '05:17', 'imsak': '05:07', 'isha': '18:56'},
    };

    for (final MapEntry(key: method, value: times) in dhaka.entries) {
      for (final (school, asr) in [(0, '15:11'), (1, '15:56')]) {
        test('Dhaka, method $method, school $school', () {
          final actual = _atOffset(6).calculate(
            date: dhakaDay,
            latitude: dhakaLat,
            longitude: dhakaLon,
            method: method,
            school: school,
          );
          _expectAladhan(actual, {...dhakaCommon, ...times, 'asr': asr});
        });
      }
    }

    // The rest of the catalog, standard Asr. Fields: Fajr, Imsak, Sunrise,
    // Dhuhr, Asr, Maghrib, Isha.
    const dhakaRest = <int, List<String>>{
      0: ['05:33', '05:23', '06:43', '12:08', '15:11', '17:48', '18:34'],
      7: ['05:25', '05:15', '06:43', '12:08', '15:11', '17:50', '18:34'],
      8: ['05:17', '05:07', '06:43', '12:08', '15:11', '17:33', '19:03'],
      9: ['05:23', '05:13', '06:43', '12:08', '15:11', '17:33', '18:50'],
      10: ['05:23', '05:13', '06:43', '12:08', '15:11', '17:33', '19:03'],
      11: ['05:14', '05:04', '06:43', '12:08', '15:11', '17:33', '18:52'],
      12: ['05:51', '05:41', '06:43', '12:08', '15:11', '17:33', '18:25'],
      13: ['05:23', '05:13', '06:36', '12:13', '15:15', '17:40', '18:47'],
      14: ['05:33', '05:23', '06:43', '12:08', '15:11', '17:33', '18:38'],
      16: ['05:23', '05:13', '06:43', '12:11', '15:11', '17:36', '18:53'],
      17: ['05:14', '05:04', '06:43', '12:08', '15:11', '17:33', '18:52'],
      18: ['05:23', '05:13', '06:43', '12:08', '15:11', '17:33', '18:52'],
      19: ['05:23', '05:13', '06:43', '12:08', '15:11', '17:33', '18:47'],
      20: ['05:14', '05:04', '06:43', '12:08', '15:11', '17:33', '18:52'],
      21: ['05:19', '05:09', '06:43', '12:13', '15:11', '17:38', '18:47'],
      22: ['05:23', '05:13', '06:43', '12:13', '15:11', '17:36', '18:53'],
      23: ['05:23', '05:13', '06:43', '12:08', '15:11', '17:38', '18:52'],
    };

    for (final MapEntry(key: method, value: t) in dhakaRest.entries) {
      test('Dhaka, method $method', () {
        final actual = _atOffset(6).calculate(
          date: dhakaDay,
          latitude: dhakaLat,
          longitude: dhakaLon,
          method: method,
          school: 0,
        );
        // Sunset is left out: Aladhan shifts it along with Maghrib for Turkey
        // and Dubai, and the app never shows it.
        _expectAladhan(actual, {
          'fajr': t[0],
          'imsak': t[1],
          'sunrise': t[2],
          'dhuhr': t[3],
          'asr': t[4],
          'maghrib': t[5],
          'isha': t[6],
          'sunset': actual.sunset,
          'midnight': '00:08',
        });
      });
    }

    test('London at the summer solstice uses the angle-based rule', () {
      // MWL's 18° Fajr never happens in a London June night, so the time
      // comes entirely from the high-latitude rule.
      final actual = _atOffset(1).calculate(
        date: DateTime(2026, 6, 21),
        latitude: 51.5074,
        longitude: -0.1278,
        method: 3,
        school: 0,
      );
      _expectAladhan(actual, {
        'fajr': '02:31',
        'imsak': '02:21',
        'sunrise': '04:43',
        'dhuhr': '13:02',
        'asr': '17:25',
        'sunset': '21:22',
        'maghrib': '21:22',
        'isha': '23:27',
        'midnight': '01:02',
      });
    });

    // Interval-Isha methods use the same angle-based rule for Fajr, which
    // never reaches its angle in a London June night.
    const londonIntervalFajr = {
      4: '02:27',
      8: '02:20',
      10: '02:31',
      22: '02:31'
    };
    for (final MapEntry(key: method, value: fajr)
        in londonIntervalFajr.entries) {
      test('London at the summer solstice, method $method', () {
        final actual = _atOffset(1).calculate(
          date: DateTime(2026, 6, 21),
          latitude: 51.5074,
          longitude: -0.1278,
          method: method,
          school: 0,
        );
        expect(actual.fajr, fajr);
      });
    }

    test('Umm al-Qura extends Isha to 120 minutes in Ramadan', () {
      // 25 Feb 2026 is in Ramadan 1447. Makkah, UTC+3.
      final actual = _atOffset(3).calculate(
        date: DateTime(2026, 2, 25),
        latitude: 21.4225,
        longitude: 39.8262,
        method: 4,
        school: 0,
      );
      expect(actual.maghrib, _within1('18:23'));
      expect(actual.isha, _within1('20:23'));
    });
  });

  group('PrayerTimesCalculator', () {
    test('an unknown method id falls back to Muslim World League', () {
      PrayerTimes calc(int method) => _atOffset(6).calculate(
            date: DateTime(2026, 1, 15),
            latitude: 23.8103,
            longitude: 90.4125,
            method: method,
            school: 0,
          );
      expect(calc(99).fajr, calc(3).fajr);
      expect(calc(99).isha, calc(3).isha);
    });

    test('Umm al-Qura does not throw at high latitude', () {
      expect(
        () => _atOffset(2).calculate(
          date: DateTime(2026, 6, 21),
          latitude: 59.9139,
          longitude: 10.7522,
          method: 4,
          school: 0,
        ),
        returnsNormally,
      );
    });

    test('rejects out-of-range coordinates', () {
      expect(
        () => _atOffset(0).calculate(
          date: DateTime(2026, 1, 15),
          latitude: 123.0,
          longitude: 0.0,
          method: 3,
          school: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
