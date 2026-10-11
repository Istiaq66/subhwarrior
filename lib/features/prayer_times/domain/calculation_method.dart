/// A prayer-time calculation method: the twilight definitions an authority
/// uses, plus the minute offsets it publishes on top of them.
///
/// The catalog is Aladhan's public method list (api.aladhan.com/v1/methods),
/// keyed by Aladhan's ids — the values this app has always stored — with the
/// offsets Aladhan applies for each. `PrayerTimesCalculator` turns one into
/// times.
class CalculationMethod {
  const CalculationMethod({
    required this.id,
    required this.name,
    required this.fajrAngle,
    this.ishaAngle,
    this.ishaIntervalMinutes,
    this.maghribAngle,
    this.sunriseOffset = 0,
    this.dhuhrOffset = 0,
    this.asrOffset = 0,
    this.maghribOffset = 0,
  }) : assert((ishaAngle == null) != (ishaIntervalMinutes == null),
            'Isha is either an angle or an interval');

  final int id;
  final String name;

  /// Sun depression for Fajr, in degrees.
  final double fajrAngle;

  /// Sun depression for Isha, in degrees. Null when Isha is an interval.
  final double? ishaAngle;

  /// Isha as a fixed number of minutes after sunset.
  final int? ishaIntervalMinutes;

  /// Sun depression for Maghrib, for methods that wait past sunset.
  final double? maghribAngle;

  /// Published offsets, in minutes, added to the computed times.
  final int sunriseOffset;
  final int dhuhrOffset;
  final int asrOffset;
  final int maghribOffset;

  static const int jafari = 0;
  static const int karachi = 1;
  static const int isna = 2;
  static const int muslimWorldLeague = 3;
  static const int ummAlQura = 4;
  static const int egyptian = 5;
  static const int tehran = 7;
  static const int gulf = 8;
  static const int kuwait = 9;
  static const int qatar = 10;
  static const int singapore = 11;
  static const int france = 12;
  static const int turkey = 13;
  static const int russia = 14;
  static const int moonsightingCommittee = 15;
  static const int dubai = 16;
  static const int jakim = 17;
  static const int tunisia = 18;
  static const int algeria = 19;
  static const int kemenag = 20;
  static const int morocco = 21;
  static const int portugal = 22;
  static const int jordan = 23;

  /// Picker order: the most widely used first, then alphabetical by region.
  static const List<CalculationMethod> all = [
    CalculationMethod(
      id: muslimWorldLeague,
      name: 'Muslim World League (MWL)',
      fajrAngle: 18,
      ishaAngle: 17,
    ),
    CalculationMethod(
      id: isna,
      name: 'Islamic Society of North America (ISNA)',
      fajrAngle: 15,
      ishaAngle: 15,
    ),
    CalculationMethod(
      id: karachi,
      name: 'University of Islamic Sciences, Karachi',
      fajrAngle: 18,
      ishaAngle: 18,
    ),
    CalculationMethod(
      id: ummAlQura,
      name: 'Umm Al-Qura University, Makkah',
      fajrAngle: 18.5,
      ishaIntervalMinutes: 90,
    ),
    CalculationMethod(
      id: egyptian,
      name: 'Egyptian General Authority of Survey',
      fajrAngle: 19.5,
      ishaAngle: 17.5,
    ),
    // Fajr and Isha come from a seasonal curve, not these angles; see
    // `PrayerTimesCalculator`.
    CalculationMethod(
      id: moonsightingCommittee,
      name: 'Moonsighting Committee Worldwide',
      fajrAngle: 18,
      ishaAngle: 18,
    ),
    CalculationMethod(
      id: algeria,
      name: 'Algeria',
      fajrAngle: 18,
      ishaAngle: 17,
    ),
    CalculationMethod(
      id: dubai,
      name: 'Dubai',
      fajrAngle: 18.2,
      ishaAngle: 18.2,
      dhuhrOffset: 3,
      maghribOffset: 3,
    ),
    CalculationMethod(
      id: gulf,
      name: 'Gulf Region',
      fajrAngle: 19.5,
      ishaIntervalMinutes: 90,
    ),
    CalculationMethod(
      id: kemenag,
      name: 'Kementerian Agama Republik Indonesia (Kemenag)',
      fajrAngle: 20,
      ishaAngle: 18,
    ),
    CalculationMethod(
      id: jordan,
      name: 'Ministry of Awqaf, Jordan',
      fajrAngle: 18,
      ishaAngle: 18,
      maghribOffset: 5,
    ),
    CalculationMethod(
      id: kuwait,
      name: 'Kuwait',
      fajrAngle: 18,
      ishaAngle: 17.5,
    ),
    CalculationMethod(
      id: jakim,
      name: 'Jabatan Kemajuan Islam Malaysia (JAKIM)',
      fajrAngle: 20,
      ishaAngle: 18,
    ),
    CalculationMethod(
      id: morocco,
      name: 'Morocco',
      fajrAngle: 19,
      ishaAngle: 17,
      dhuhrOffset: 5,
      maghribOffset: 5,
    ),
    // Isha is 77 minutes after a Maghrib that is itself 3 after sunset.
    CalculationMethod(
      id: portugal,
      name: 'Comunidade Islâmica de Lisboa',
      fajrAngle: 18,
      ishaIntervalMinutes: 80,
      dhuhrOffset: 5,
      maghribOffset: 3,
    ),
    CalculationMethod(
      id: qatar,
      name: 'Qatar',
      fajrAngle: 18,
      ishaIntervalMinutes: 90,
    ),
    CalculationMethod(
      id: russia,
      name: 'Spiritual Administration of Muslims of Russia',
      fajrAngle: 16,
      ishaAngle: 15,
    ),
    CalculationMethod(
      id: singapore,
      name: 'Majlis Ugama Islam Singapura',
      fajrAngle: 20,
      ishaAngle: 18,
    ),
    CalculationMethod(
      id: tunisia,
      name: 'Tunisia',
      fajrAngle: 18,
      ishaAngle: 18,
    ),
    CalculationMethod(
      id: turkey,
      name: 'Diyanet İşleri Başkanlığı, Turkey',
      fajrAngle: 18,
      ishaAngle: 17,
      sunriseOffset: -7,
      dhuhrOffset: 5,
      asrOffset: 4,
      maghribOffset: 7,
    ),
    CalculationMethod(
      id: france,
      name: 'Union des Organisations Islamiques de France',
      fajrAngle: 12,
      ishaAngle: 12,
    ),
    CalculationMethod(
      id: tehran,
      name: 'Institute of Geophysics, University of Tehran',
      fajrAngle: 17.7,
      ishaAngle: 14,
      maghribAngle: 4.5,
    ),
    CalculationMethod(
      id: jafari,
      name: 'Shia Ithna-Ashari, Leva Institute, Qum',
      fajrAngle: 16,
      ishaAngle: 14,
      maghribAngle: 4,
    ),
  ];

  static final Map<int, CalculationMethod> _byId = {
    for (final method in all) method.id: method,
  };

  /// The method stored as [id]. An id this build does not know falls back to
  /// Muslim World League rather than failing.
  static CalculationMethod byId(int id) =>
      _byId[id] ?? _byId[muslimWorldLeague]!;
}
