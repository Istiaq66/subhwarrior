/// Immutable prayer timings for a single day. Times are "HH:mm" strings in
/// local time, stripped of the Aladhan timezone suffix (e.g. "05:30 (+06)").
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

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    // Remove timezone info (e.g. "(+06)" from "05:30 (+06)").
    String cleanTime(String time) => time.split(' ')[0];

    return PrayerTimes(
      fajr: cleanTime(json['Fajr'] ?? '00:00'),
      sunrise: cleanTime(json['Sunrise'] ?? '00:00'),
      dhuhr: cleanTime(json['Dhuhr'] ?? '00:00'),
      asr: cleanTime(json['Asr'] ?? '00:00'),
      sunset: cleanTime(json['Sunset'] ?? '00:00'),
      maghrib: cleanTime(json['Maghrib'] ?? '00:00'),
      isha: cleanTime(json['Isha'] ?? '00:00'),
      imsak: cleanTime(json['Imsak'] ?? '00:00'),
      midnight: cleanTime(json['Midnight'] ?? '00:00'),
    );
  }

  /// Round-trip form for the local cache. Deliberately separate from
  /// [PrayerTimes.fromJson], which parses the Aladhan payload (capitalised
  /// keys, timezone suffixes) — cached values are already cleaned.
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
