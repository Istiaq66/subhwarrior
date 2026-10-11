import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/prayer_times/domain/calculation_method.dart';
import 'package:subh_warrior/features/prayer_times/domain/country_prayer_defaults.dart';

void main() {
  group('CountryPrayerDefaults.forCountry', () {
    test('uses the national method and school where one is listed', () {
      final bd = CountryPrayerDefaults.forCountry('BD');
      expect(bd.calculationMethod, CalculationMethod.karachi);
      expect(bd.useHanafiMethod, isTrue);

      final my = CountryPrayerDefaults.forCountry('MY');
      expect(my.calculationMethod, CalculationMethod.jakim);
      expect(my.useHanafiMethod, isFalse);
    });

    test('matches case-insensitively', () {
      expect(CountryPrayerDefaults.forCountry(' tr ').calculationMethod,
          CalculationMethod.turkey);
    });

    test('a Hanafi country without its own method keeps the fallback method',
        () {
      final uz = CountryPrayerDefaults.forCountry('UZ');
      expect(uz.calculationMethod, CalculationMethod.muslimWorldLeague);
      expect(uz.useHanafiMethod, isTrue);
    });

    test('unknown or missing countries fall back to MWL, standard Asr', () {
      for (final code in [null, '', 'ZZ']) {
        final defaults = CountryPrayerDefaults.forCountry(code);
        expect(defaults.calculationMethod,
            CountryPrayerDefaults.fallback.calculationMethod);
        expect(defaults.useHanafiMethod, isFalse);
      }
    });

    test('every listed method exists in the catalog', () {
      const codes = [
        'AE',
        'BH',
        'DZ',
        'EG',
        'FR',
        'ID',
        'IR',
        'JO',
        'KW',
        'MA',
        'PT',
        'QA',
        'RU',
        'SA',
        'SG',
        'TN',
        'US'
      ];
      for (final code in codes) {
        final id = CountryPrayerDefaults.forCountry(code).calculationMethod;
        expect(CalculationMethod.byId(id).id, id, reason: code);
      }
    });
  });

  group('CalculationMethod', () {
    test('ids are unique', () {
      final ids = CalculationMethod.all.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('an unknown id falls back to Muslim World League', () {
      expect(
          CalculationMethod.byId(99).id, CalculationMethod.muslimWorldLeague);
    });
  });
}
