import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/features/location/data/city_catalog.dart';

const _json = '''
{"countries":{"BD":"Bangladesh","FJ":"Fiji","TR":"Türkiye"},
 "cities":[
  ["Chattogram","BD",22.3384,91.8317,"Chittagong"],
  ["Dhaka","BD",23.7104,90.4074],
  ["Suva","FJ",-18.1416,178.4415],
  ["Ankara","TR",39.9199,32.8543]
 ]}''';

void main() {
  final catalog = CityCatalog.fromJson(_json);

  group('CityCatalog', () {
    test('labels cities with their country name', () {
      expect(catalog.cities[1].label, 'Dhaka, Bangladesh');
      expect(catalog.cities[1].countryCode, 'BD');
    });

    test('an empty query lists every city', () {
      expect(catalog.search('  '), hasLength(4));
    });

    test('matches the ASCII spelling and the country, name prefixes first', () {
      expect(catalog.search('chittagong').single.name, 'Chattogram');
      expect(
          catalog.search('bangla').map((c) => c.name), ['Chattogram', 'Dhaka']);
      // "an" starts Ankara and appears inside "Bangladesh".
      expect(catalog.search('an').first.name, 'Ankara');
    });

    test('nearest finds the closest city, across the antimeridian too', () {
      expect(catalog.nearest(23.8, 90.4).name, 'Dhaka');
      expect(catalog.nearest(-18.0, -179.9).name, 'Suva');
    });

    test('a device fix keeps its own coordinates under the city name', () {
      final fix = catalog.nearest(23.75, 90.39).at(23.75, 90.39);
      expect(fix.label, 'Dhaka, Bangladesh');
      expect(fix.latitude, 23.75);
    });
  });

  test('the bundled asset loads and includes Dhaka', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final bundled = await CityCatalog.load();
    expect(bundled.cities.length, greaterThan(10000));
    expect(bundled.search('dhaka').first.label, 'Dhaka, Bangladesh');
  });
}
