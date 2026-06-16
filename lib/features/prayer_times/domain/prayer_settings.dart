/// User-chosen prayer-time calculation preferences.
class PrayerSettings {
  /// Aladhan calculation method (2 = ISNA, 3 = MWL, …).
  final int calculationMethod;

  /// Juristic school for Asr: Hanafi (school=1) vs Standard/Shafi (school=0).
  final bool useHanafiMethod;

  /// Display clock in 24-hour (`14:30`) vs 12-hour (`02:30 PM`) format.
  final bool use24HourFormat;

  const PrayerSettings({
    this.calculationMethod = defaultCalculationMethod,
    this.useHanafiMethod = false,
    this.use24HourFormat = false,
  });

  static const int defaultCalculationMethod = 2;

  /// Aladhan `school` query value derived from the juristic method.
  int get school => useHanafiMethod ? 1 : 0;

  PrayerSettings copyWith({
    int? calculationMethod,
    bool? useHanafiMethod,
    bool? use24HourFormat,
  }) =>
      PrayerSettings(
        calculationMethod: calculationMethod ?? this.calculationMethod,
        useHanafiMethod: useHanafiMethod ?? this.useHanafiMethod,
        use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      );
}
