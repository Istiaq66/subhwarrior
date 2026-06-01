/// User-chosen prayer-time calculation preferences.
class PrayerSettings {
  /// Aladhan calculation method (2 = ISNA, 3 = MWL, …).
  final int calculationMethod;

  /// Juristic school for Asr: Hanafi (school=1) vs Standard/Shafi (school=0).
  final bool useHanafiMethod;

  const PrayerSettings({
    this.calculationMethod = defaultCalculationMethod,
    this.useHanafiMethod = false,
  });

  static const int defaultCalculationMethod = 2;

  /// Aladhan `school` query value derived from the juristic method.
  int get school => useHanafiMethod ? 1 : 0;

  PrayerSettings copyWith({int? calculationMethod, bool? useHanafiMethod}) =>
      PrayerSettings(
        calculationMethod: calculationMethod ?? this.calculationMethod,
        useHanafiMethod: useHanafiMethod ?? this.useHanafiMethod,
      );
}
