import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../domain/city.dart';

/// The bundled city list: GeoNames cities of 50,000+ people plus every
/// capital (geonames.org, CC BY 4.0; rebuilt by `tool/build_cities.py`).
class CityCatalog {
  CityCatalog._(this.cities, this._searchText);

  /// Parses the asset's JSON: `countries` maps ISO code to name, and each of
  /// `cities` is `[name, countryCode, lat, lon, asciiName?]`.
  factory CityCatalog.fromJson(String source) {
    final data = json.decode(source) as Map<String, dynamic>;
    final countries = (data['countries'] as Map).cast<String, String>();
    final cities = <City>[];
    final searchText = <String>[];
    for (final row in data['cities'] as List) {
      final r = row as List;
      final city = City(
        name: r[0] as String,
        countryCode: r[1] as String,
        countryName: countries[r[1]]!,
        latitude: (r[2] as num).toDouble(),
        longitude: (r[3] as num).toDouble(),
      );
      cities.add(city);
      searchText.add(
          '${city.name} ${r.length > 4 ? r[4] : ''} ${city.countryName}'
              .toLowerCase());
    }
    return CityCatalog._(cities, searchText);
  }

  static const asset = 'assets/data/cities.json';

  /// Sorted by country, then city.
  final List<City> cities;
  final List<String> _searchText;

  static Future<CityCatalog>? _loaded;

  static Future<CityCatalog> load() =>
      _loaded ??= rootBundle.loadString(asset).then(CityCatalog.fromJson);

  /// Cities whose name (or ASCII spelling) or country contains [query], with
  /// those whose name starts with it first.
  List<City> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return cities;
    final starts = <City>[];
    final contains = <City>[];
    for (var i = 0; i < cities.length; i++) {
      if (!_searchText[i].contains(q)) continue;
      (_searchText[i].startsWith(q) ? starts : contains).add(cities[i]);
    }
    return [...starts, ...contains];
  }

  /// The listed city closest to a position.
  City nearest(double latitude, double longitude) {
    final cosLat = math.cos(latitude * math.pi / 180);
    double distance(City c) {
      final dLat = c.latitude - latitude;
      final dLon = ((c.longitude - longitude + 540) % 360 - 180) * cosLat;
      return dLat * dLat + dLon * dLon;
    }

    return cities.reduce((a, b) => distance(a) <= distance(b) ? a : b);
  }
}
