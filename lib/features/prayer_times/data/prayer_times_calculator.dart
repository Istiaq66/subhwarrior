import 'package:adhan/adhan.dart' as adhan;

import '../domain/calculation_method.dart';
import '../domain/prayer_times.dart';
import '../domain/umm_al_qura_ramadan.dart';

/// Computes prayer times on the device with the `adhan` package — no network,
/// so times are available for any day the app is opened, connected or not.
///
/// `method` is a [CalculationMethod] id (Aladhan's numbering, which the app
/// has always stored) and `school` is Aladhan's 0 = Standard, 1 = Hanafi.
/// Output mirrors what the Aladhan API returned, including its derived Imsak
/// and Midnight, so nothing downstream of [PrayerTimes] changes.
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

  /// Aladhan's default Imsak: a fixed ten minutes before Fajr.
  static const _imsakLead = Duration(minutes: 10);

  /// Umm al-Qura's Isha moves from 90 to 120 minutes after Maghrib during
  /// Ramadan. Aladhan applies this; `adhan` does not.
  static const _ummAlQuraRamadanExtra = Duration(minutes: 30);

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
    final coordinates = adhan.Coordinates(latitude, longitude, validate: true);
    final spec = CalculationMethod.byId(method);
    final params = _parameters(spec, school);

    final day = DateTime(date.year, date.month, date.day);
    final components = adhan.DateComponents.from(day);
    final today = adhan.PrayerTimes(coordinates, components, params);
    final nextDay = adhan.PrayerTimes(coordinates,
        adhan.DateComponents.from(day.add(const Duration(days: 1))), params);

    // Maghrib is sunset unless the method waits for a Maghrib angle; only
    // then is a separate sunset needed.
    final sunset = spec.maghribAngle == null
        ? today.maghrib
        : adhan.PrayerTimes(coordinates, components,
                adhan.CalculationParameters(fajrAngle: 18, ishaAngle: 17))
            .maghrib;
    var fajr = today.fajr;
    var isha = today.isha;

    // `adhan` takes the later of 18° and the seasonal curve for Fajr, and the
    // earlier for Isha. The Committee — and Aladhan — use the curve alone,
    // which put Fajr up to several minutes apart.
    if (spec.id == CalculationMethod.moonsightingCommittee &&
        latitude < _moonsightingSeasonalMaxLatitude) {
      final dyy = adhan.PrayerTimes.daysSinceSolstice(
          _dayOfYear(day), day.year, latitude);
      fajr = today.sunrise
          .subtract(_seasonalMinutes(_moonsightingMorning, latitude, dyy));
      isha = sunset.add(_seasonalMinutes(_moonsightingEvening, latitude, dyy));
    }

    if (spec.id == CalculationMethod.ummAlQura &&
        UmmAlQuraRamadan.contains(day)) {
      isha = isha.add(_ummAlQuraRamadanExtra);
    }

    Duration minutes(int n) => Duration(minutes: n);
    return PrayerTimes(
      fajr: _hhmm(fajr),
      sunrise: _hhmm(today.sunrise.add(minutes(spec.sunriseOffset))),
      dhuhr: _hhmm(today.dhuhr.add(minutes(spec.dhuhrOffset))),
      asr: _hhmm(today.asr.add(minutes(spec.asrOffset))),
      sunset: _hhmm(sunset),
      maghrib: _hhmm(today.maghrib.add(minutes(spec.maghribOffset))),
      isha: _hhmm(isha),
      imsak: _hhmm(fajr.subtract(_imsakLead)),
      // Aladhan's Standard midnight: halfway from sunset to the next sunrise.
      midnight: _hhmm(sunset.add(nextDay.sunrise.difference(sunset) ~/ 2)),
    );
  }

  /// `adhan` parameters for [spec]. Offsets are left out and added to the
  /// results instead, so `adhan`'s Maghrib stays the raw sunset the derived
  /// times are measured from.
  static adhan.CalculationParameters _parameters(
      CalculationMethod spec, int school) {
    final params = spec.id == CalculationMethod.moonsightingCommittee
        // The adhan method value switches on its seventh-of-the-night rule
        // above 55°; its own offsets are not Aladhan's and are cleared.
        ? (adhan.CalculationMethod.moon_sighting_committee.getParameters()
          ..methodAdjustments = adhan.PrayerAdjustments())
        : adhan.CalculationParameters(
            fajrAngle: spec.fajrAngle,
            // `adhan` needs an Isha angle for the angle-based rule even when
            // Isha is an interval. The interval still decides Isha; this
            // placeholder is never used for it.
            ishaAngle: spec.ishaAngle ?? spec.fajrAngle,
            ishaInterval: spec.ishaIntervalMinutes ?? 0,
            maghribAngle: spec.maghribAngle,
          );
    // Aladhan's default high-latitude rule, for every method: where the
    // twilight angle is never reached, Fajr is that fraction (angle / 60) of
    // the night before sunrise.
    return params
      ..madhab = school == 1 ? adhan.Madhab.hanafi : adhan.Madhab.shafi
      ..highLatitudeRule = adhan.HighLatitudeRule.twilight_angle;
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
