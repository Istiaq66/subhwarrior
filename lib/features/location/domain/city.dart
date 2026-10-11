/// A place prayer times are calculated for: a city from the bundled list, or
/// a device fix named after its nearest city.
class City {
  const City({
    required this.name,
    required this.countryName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String countryName;

  /// ISO 3166-1 alpha-2; picks the country's prayer defaults.
  final String countryCode;
  final double latitude;
  final double longitude;

  /// What the profile stores and the local leaderboard groups by, so it must
  /// be identical for everyone in the same city.
  String get label => '$name, $countryName';

  /// This city's name at another position — a device fix near it.
  City at(double latitude, double longitude) => City(
        name: name,
        countryName: countryName,
        countryCode: countryCode,
        latitude: latitude,
        longitude: longitude,
      );
}
