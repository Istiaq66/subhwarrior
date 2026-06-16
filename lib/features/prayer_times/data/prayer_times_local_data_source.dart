import 'package:shared_preferences/shared_preferences.dart';

import '../domain/prayer_settings.dart';

/// Reads/writes prayer calculation preferences to [SharedPreferences].
class PrayerTimesLocalDataSource {
  final SharedPreferences prefs;

  PrayerTimesLocalDataSource(this.prefs);

  static const _kMethod = 'prayer_calculation_method';
  static const _kHanafi = 'prayer_hanafi_method';
  static const _k24Hour = 'clock_24_hour_format';

  PrayerSettings load() => PrayerSettings(
        calculationMethod:
            prefs.getInt(_kMethod) ?? PrayerSettings.defaultCalculationMethod,
        useHanafiMethod: prefs.getBool(_kHanafi) ?? false,
        use24HourFormat: prefs.getBool(_k24Hour) ?? false,
      );

  Future<void> save(PrayerSettings settings) async {
    await prefs.setInt(_kMethod, settings.calculationMethod);
    await prefs.setBool(_kHanafi, settings.useHanafiMethod);
    await prefs.setBool(_k24Hour, settings.use24HourFormat);
  }
}
