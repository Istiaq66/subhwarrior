/// Immutable prayer timings for a single day. Times are "HH:mm" strings in
/// local time.
class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
  });

  /// Round-trip form for the local cache.
  Map<String, dynamic> toCacheMap() => {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'sunset': sunset,
        'maghrib': maghrib,
        'isha': isha,
        'imsak': imsak,
        'midnight': midnight,
      };

  factory PrayerTimes.fromCacheMap(Map<String, dynamic> map) => PrayerTimes(
        fajr: map['fajr'] as String? ?? '00:00',
        sunrise: map['sunrise'] as String? ?? '00:00',
        dhuhr: map['dhuhr'] as String? ?? '00:00',
        asr: map['asr'] as String? ?? '00:00',
        sunset: map['sunset'] as String? ?? '00:00',
        maghrib: map['maghrib'] as String? ?? '00:00',
        isha: map['isha'] as String? ?? '00:00',
        imsak: map['imsak'] as String? ?? '00:00',
        midnight: map['midnight'] as String? ?? '00:00',
      );
}
