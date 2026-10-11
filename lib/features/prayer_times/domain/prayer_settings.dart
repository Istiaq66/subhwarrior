/// User-chosen prayer-time calculation preferences.
class PrayerSettings {
  /// Calculation method as an Aladhan method id (2 = ISNA, 3 = MWL, …) — the
  /// app's stored vocabulary, mapped onto `adhan` by `PrayerTimesCalculator`.
  final int calculationMethod;

  /// Juristic school for Asr: Hanafi (school=1) vs Standard/Shafi (school=0).
  final bool useHanafiMethod;

  /// Display clock in 24-hour (`14:30`) vs 12-hour (`02:30 PM`) format.
  final bool use24HourFormat;

  /// ISO code of the country whose defaults were last applied, so a location
  /// change only re-applies them on moving country. Null for profiles that
  /// predate country defaults.
  final String? defaultsCountryCode;

  const PrayerSettings({
    this.calculationMethod = defaultCalculationMethod,
    this.useHanafiMethod = false,
    this.use24HourFormat = false,
    this.defaultsCountryCode,
  });

  static const int defaultCalculationMethod = 2;

  /// Aladhan-style `school` value derived from the juristic method.
  int get school => useHanafiMethod ? 1 : 0;

  PrayerSettings copyWith({
    int? calculationMethod,
    bool? useHanafiMethod,
    bool? use24HourFormat,
    String? defaultsCountryCode,
  }) =>
      PrayerSettings(
        calculationMethod: calculationMethod ?? this.calculationMethod,
        useHanafiMethod: useHanafiMethod ?? this.useHanafiMethod,
        use24HourFormat: use24HourFormat ?? this.use24HourFormat,
        defaultsCountryCode: defaultsCountryCode ?? this.defaultsCountryCode,
      );
}
