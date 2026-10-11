import 'package:adhan/adhan.dart' as adhan;

import '../../../core/utils/hijri_date.dart';
import '../domain/prayer_times.dart';

/// Computes prayer times on the device with the `adhan` package — no network,
/// so times are available for any day the app is opened, connected or not.
///
/// Inputs keep the Aladhan vocabulary the app has always stored: `method` is an
/// Aladhan method id (persisted in prefs by older builds, and the keys of the
/// Settings picker) and `school` is Aladhan's 0 = Standard, 1 = Hanafi. Output
/// mirrors what the Aladhan API returned, including its derived Imsak and
/// Midnight, so nothing downstream of [PrayerTimes] changes.
///
/// Times are rendered in the device's time zone. That matches the old API for
/// the app's real use — the user's own location — but a profile set to a city
/// in another zone would now get that city's times on the device's clock.
class PrayerTimesCalculator {
  /// [toLocal] places an instant on the wall clock the times are shown in.
  /// Defaults to the device zone; tests pin a fixed offset.
  const PrayerTimesCalculator({DateTime Function(DateTime)? toLocal})
      : _toLocal = toLocal ?? _deviceLocal;

  final DateTime Function(DateTime) _toLocal;

  static DateTime _deviceLocal(DateTime time) => time.toLocal();

  /// Aladhan method id → adhan method. Covers every id the Settings picker
  /// offers; anything else (a value from a build with a longer list) falls
  /// back to [_fallbackMethod].
  static const Map<int, adhan.CalculationMethod> _methods = {
    1: adhan.CalculationMethod.karachi,
    2: adhan.CalculationMethod.north_america,
    3: adhan.CalculationMethod.muslim_world_league,
    4: adhan.CalculationMethod.umm_al_qura,
    5: adhan.CalculationMethod.egyptian,
    15: adhan.CalculationMethod.moon_sighting_committee,
  };

  static const _fallbackMethod = adhan.CalculationMethod.muslim_world_league;

  /// Aladhan's default Imsak: a fixed ten minutes before Fajr.
  static const _imsakLead = Duration(minutes: 10);

  /// Umm al-Qura's Isha moves from 90 to 120 minutes after Maghrib during
  /// Ramadan. Aladhan applies this; `adhan` does not.
  static const _ummAlQuraRamadanExtra = Duration(minutes: 30);

  static const _ramadan = 9;

  /// Moonsighting Committee's seasonal curves, per 55° of latitude, at the
  /// four turning points of its year (see [_seasonalMinutes]).
  static const _moonsightingMorning = [28.65, 19.44, 32.74, 48.10];
  static const _moonsightingEvening = [25.60, 2.05, -9.21, 6.14];

  /// Above this latitude Moonsighting Committee switches to a seventh of the
  /// night, which `adhan` already implements.
  static const _moonsightingSeasonalMaxLatitude = 55.0;

  /// Throws [ArgumentError] for coordinates outside ±90 / ±180, which a
  /// corrupt profile could carry; callers already treat a throw as a failed
  /// lookup.
  PrayerTimes calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required int method,
    required int school,
  }) {
    final coordinates =
        adhan.Coordinates(latitude, longitude, validate: true);
    final params = _parameters(method, school);

    final day = DateTime(date.year, date.month, date.day);
    final today = adhan.PrayerTimes(
        coordinates, adhan.DateComponents.from(day), params);
    final nextDay = adhan.PrayerTimes(coordinates,
        adhan.DateComponents.from(day.add(const Duration(days: 1))), params);

    // With the method offsets cleared, Maghrib is sunset for every method the
    // picker offers (only Tehran sets a Maghrib angle).
    final sunset = today.maghrib;
    var fajr = today.fajr;
    var isha = today.isha;

    // `adhan` takes the later of 18° and the seasonal curve for Fajr, and the
    // earlier for Isha. The Committee — and Aladhan — use the curve alone,
    // which put Fajr up to several minutes apart.
    if (params.method == adhan.CalculationMethod.moon_sighting_committee &&
        latitude < _moonsightingSeasonalMaxLatitude) {
      final dyy = adhan.PrayerTimes.daysSinceSolstice(
          _dayOfYear(day), day.year, latitude);
      fajr = today.sunrise.subtract(
          _seasonalMinutes(_moonsightingMorning, latitude, dyy));
      isha = sunset.add(_seasonalMinutes(_moonsightingEvening, latitude, dyy));
    }

    if (params.method == adhan.CalculationMethod.umm_al_qura &&
        HijriDate.fromDateTime(day).month == _ramadan) {
      isha = isha.add(_ummAlQuraRamadanExtra);
    }

    return PrayerTimes(
      fajr: _hhmm(fajr),
      sunrise: _hhmm(today.sunrise),
      dhuhr: _hhmm(today.dhuhr),
      asr: _hhmm(today.asr),
      sunset: _hhmm(sunset),
      maghrib: _hhmm(today.maghrib),
      isha: _hhmm(isha),
      imsak: _hhmm(fajr.subtract(_imsakLead)),
      // Aladhan's Standard midnight: halfway from sunset to the next sunrise.
      midnight: _hhmm(sunset.add(nextDay.sunrise.difference(sunset) ~/ 2)),
    );
  }

  static adhan.CalculationParameters _parameters(int method, int school) {
    final params = (_methods[method] ?? _fallbackMethod).getParameters()
      ..madhab = school == 1 ? adhan.Madhab.hanafi : adhan.Madhab.shafi
      // `adhan` pads some methods (Dhuhr +1 minute, Moonsighting Committee
      // Dhuhr +5 and Maghrib +3). Aladhan does not, and these are the times
      // users already have.
      ..methodAdjustments = adhan.PrayerAdjustments();
    // Aladhan's default high-latitude rule is angle based. `adhan` can only
    // apply it with an Isha angle — Umm al-Qura uses a fixed interval and
    // would throw — so those methods keep `adhan`'s middle-of-the-night rule.
    if (params.ishaAngle != null) {
      params.highLatitudeRule = adhan.HighLatitudeRule.twilight_angle;
    }
    return params;
  }

  /// Moonsighting Committee's twilight length: 75 minutes plus a
  /// latitude-scaled term, interpolated linearly between four points of the
  /// year counted from the winter solstice. Ported from `adhan`, which keeps
  /// it private.
  static Duration _seasonalMinutes(
      List<double> perLatitude, double latitude, int dyy) {
    final k = [for (final v in perLatitude) 75 + v / 55.0 * latitude.abs()];
    final (a, b, c, d) = (k[0], k[1], k[2], k[3]);
    final double minutes;
    if (dyy < 91) {
      minutes = a + (b - a) / 91.0 * dyy;
    } else if (dyy < 137) {
      minutes = b + (c - b) / 46.0 * (dyy - 91);
    } else if (dyy < 183) {
      minutes = c + (d - c) / 46.0 * (dyy - 137);
    } else if (dyy < 229) {
      minutes = d + (c - d) / 46.0 * (dyy - 183);
    } else if (dyy < 275) {
      minutes = c + (b - c) / 46.0 * (dyy - 229);
    } else {
      minutes = b + (a - b) / 91.0 * (dyy - 275);
    }
    return Duration(seconds: (minutes * 60).round());
  }

  static int _dayOfYear(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day)
          .difference(DateTime.utc(day.year))
          .inDays +
      1;

  /// Nearest minute. `adhan` already rounds the prayers themselves; this
  /// rounds the derived ones (midpoint, seasonal curves), which need not land
  /// on a whole minute.
  String _hhmm(DateTime time) {
    final local = _toLocal(time.add(const Duration(seconds: 30)));
    return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
