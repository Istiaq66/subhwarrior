import 'calculation_method.dart';

/// The calculation method and Asr school a country's mosques customarily use,
/// applied when the user sets a location so most people never need to open
/// the prayer settings.
///
/// Keyed by ISO 3166-1 alpha-2 code. A method is listed where a national or
/// regional authority publishes one (matching Aladhan's catalog); everywhere
/// else falls back to Muslim World League. Hanafi is listed where it is the
/// majority school; everywhere else uses the standard Asr.
class CountryPrayerDefaults {
  const CountryPrayerDefaults({
    required this.calculationMethod,
    required this.useHanafiMethod,
  });

  final int calculationMethod;
  final bool useHanafiMethod;

  static const fallback = CountryPrayerDefaults(
    calculationMethod: CalculationMethod.muslimWorldLeague,
    useHanafiMethod: false,
  );

  static const Map<String, int> _methods = {
    // South Asia
    'AF': CalculationMethod.karachi,
    'BD': CalculationMethod.karachi,
    'IN': CalculationMethod.karachi,
    'LK': CalculationMethod.karachi,
    'NP': CalculationMethod.karachi,
    'PK': CalculationMethod.karachi,
    // North America
    'CA': CalculationMethod.isna,
    'US': CalculationMethod.isna,
    // Arabian Peninsula
    'AE': CalculationMethod.dubai,
    'BH': CalculationMethod.gulf,
    'KW': CalculationMethod.kuwait,
    'OM': CalculationMethod.gulf,
    'QA': CalculationMethod.qatar,
    'SA': CalculationMethod.ummAlQura,
    'YE': CalculationMethod.ummAlQura,
    // Egypt, the Nile valley and the Levant
    'EG': CalculationMethod.egyptian,
    'IQ': CalculationMethod.egyptian,
    'LB': CalculationMethod.egyptian,
    'LY': CalculationMethod.egyptian,
    'PS': CalculationMethod.egyptian,
    'SD': CalculationMethod.egyptian,
    'SY': CalculationMethod.egyptian,
    'JO': CalculationMethod.jordan,
    // Maghreb
    'DZ': CalculationMethod.algeria,
    'MA': CalculationMethod.morocco,
    'TN': CalculationMethod.tunisia,
    // Southeast Asia
    'BN': CalculationMethod.singapore,
    'ID': CalculationMethod.kemenag,
    'MY': CalculationMethod.jakim,
    'SG': CalculationMethod.singapore,
    // Europe
    'FR': CalculationMethod.france,
    'PT': CalculationMethod.portugal,
    'RU': CalculationMethod.russia,
    'TR': CalculationMethod.turkey,
    // Iran
    'IR': CalculationMethod.tehran,
  };

  static const Set<String> _hanafi = {
    // South Asia
    'AF', 'BD', 'IN', 'NP', 'PK',
    // Turkey, Russia and Central Asia
    'KG', 'KZ', 'RU', 'TJ', 'TM', 'TR', 'UZ',
    // The Balkans
    'AL', 'BA', 'MK', 'XK',
    // China
    'CN',
  };

  /// Defaults for [countryCode] (case-insensitive), or [fallback] when it is
  /// null or unknown.
  static CountryPrayerDefaults forCountry(String? countryCode) {
    final code = countryCode?.trim().toUpperCase();
    if (code == null || code.isEmpty) return fallback;
    return CountryPrayerDefaults(
      calculationMethod: _methods[code] ?? fallback.calculationMethod,
      useHanafiMethod: _hanafi.contains(code),
    );
  }
}
