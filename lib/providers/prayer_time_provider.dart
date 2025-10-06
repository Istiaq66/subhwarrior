import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class PrayerTimeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  PrayerTimes? _todayPrayerTimes;
  PrayerTimes? _tomorrowPrayerTimes;
  bool _isLoading = false;
  String _error = '';

  // Calculation method (2 = ISNA, 3 = MWL, etc.)
  int _calculationMethod = 2;
  bool _useHanafiMethod = false; // Add Hanafi juristic method tracking

  PrayerTimes? get todayPrayerTimes => _todayPrayerTimes;
  PrayerTimes? get tomorrowPrayerTimes => _tomorrowPrayerTimes;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get calculationMethod => _calculationMethod;
  bool get useHanafiMethod => _useHanafiMethod;

  PrayerTimeProvider(this.prefs) {
    _loadData();
  }

  Future<void> _loadData() async {
    _calculationMethod = prefs.getInt('prayer_calculation_method') ?? 2;
    _useHanafiMethod = prefs.getBool('prayer_hanafi_method') ?? false;
  }

  // Get current Fajr time
  DateTime? get todayFajrTime {
    if (_todayPrayerTimes == null) return null;

    final now = DateTime.now();
    final fajrTimeStr = _todayPrayerTimes!.fajr;
    final parts = fajrTimeStr.split(':');

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // Get tomorrow's Fajr time
  DateTime? get tomorrowFajrTime {
    if (_tomorrowPrayerTimes == null) return null;

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final fajrTimeStr = _tomorrowPrayerTimes!.fajr;
    final parts = fajrTimeStr.split(':');

    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // Check if current time is within Fajr prayer window
  bool isWithinFajrTime() {
    if (_todayPrayerTimes == null) return false;

    final now = DateTime.now();
    final fajrTime = todayFajrTime;
    final sunriseTime = _parsePrayerTime(_todayPrayerTimes!.sunrise);

    if (fajrTime == null || sunriseTime == null) return false;

    return now.isAfter(fajrTime) && now.isBefore(sunriseTime);
  }

  // Fetch prayer times using Aladhan API
  Future<void> fetchPrayerTimes(double latitude, double longitude) async {
    _isLoading = true;
    _error = '';

    // Defer the notification to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final today = DateTime.now();
      final todayUrl = _buildApiUrl(today, latitude, longitude);
      final todayResponse = await http.get(Uri.parse(todayUrl));

      if (todayResponse.statusCode == 200) {
        final todayData = json.decode(todayResponse.body);
        debugPrint("Today Data: $todayData");
        _todayPrayerTimes = PrayerTimes.fromJson(todayData['data']['timings']);
      }

      // Fetch tomorrow's prayer times
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowUrl = _buildApiUrl(tomorrow, latitude, longitude);
      final tomorrowResponse = await http.get(Uri.parse(tomorrowUrl));

      if (tomorrowResponse.statusCode == 200) {
        final tomorrowData = json.decode(tomorrowResponse.body);
        _tomorrowPrayerTimes = PrayerTimes.fromJson(tomorrowData['data']['timings']);
      }

    } catch (e) {
      _error = 'Failed to fetch prayer times: $e';
    } finally {
      _isLoading = false;
      // Defer the notification to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Get prayer times by city name
  Future<void> fetchPrayerTimesByCity(String city, String country) async {
    _isLoading = true;
    _error = '';

    // Defer the notification to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final today = DateTime.now();
      final school = _useHanafiMethod ? 1 : 0;
      final todayUrl = 'http://api.aladhan.com/v1/timingsByCity/${today.day}-${today.month}-${today.year}'
          '?city=$city&country=$country&method=$_calculationMethod&school=$school';

      final todayResponse = await http.get(Uri.parse(todayUrl));

      if (todayResponse.statusCode == 200) {
        final todayData = json.decode(todayResponse.body);
        _todayPrayerTimes = PrayerTimes.fromJson(todayData['data']['timings']);
      }

      // Fetch tomorrow's times
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowUrl = 'http://api.aladhan.com/v1/timingsByCity/${tomorrow.day}-${tomorrow.month}-${tomorrow.year}'
          '?city=$city&country=$country&method=$_calculationMethod&school=$school';

      final tomorrowResponse = await http.get(Uri.parse(tomorrowUrl));

      if (tomorrowResponse.statusCode == 200) {
        final tomorrowData = json.decode(tomorrowResponse.body);
        _tomorrowPrayerTimes = PrayerTimes.fromJson(tomorrowData['data']['timings']);
      }

    } catch (e) {
      _error = 'Failed to fetch prayer times: $e';
    } finally {
      _isLoading = false;
      // Defer the notification to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Get current location and fetch prayer times
  Future<void> fetchPrayerTimesForCurrentLocation() async {
    try {
      final position = await _determinePosition();
      await fetchPrayerTimes(position.latitude, position.longitude);
    } catch (e) {
      _error = 'Failed to get location: $e';
      notifyListeners();
    }
  }

  // Update calculation method
  void updateCalculationMethod(int method) {
    _calculationMethod = method;
    prefs.setInt('prayer_calculation_method', method);
    notifyListeners();
  }

  // Update juristic method (Hanafi vs Standard)
  void updateJuristicMethod(bool useHanafi) {
    _useHanafiMethod = useHanafi;
    prefs.setBool('prayer_hanafi_method', useHanafi);
    notifyListeners();
  }

  // Helper to build API URL
  String _buildApiUrl(DateTime date, double latitude, double longitude) {
    final dateStr = '${date.day}-${date.month}-${date.year}';
    // Add school parameter: 0 for Standard (Shafi), 1 for Hanafi
    final school = _useHanafiMethod ? 1 : 0;
    return 'http://api.aladhan.com/v1/timings/$dateStr'
        '?latitude=$latitude&longitude=$longitude&method=$_calculationMethod&school=$school';
  }

  // Parse prayer time string to DateTime
  DateTime? _parsePrayerTime(String timeStr) {
    try {
      final now = DateTime.now();
      final parts = timeStr.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  // Determine current position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return await Geolocator.getCurrentPosition();
  }

  // Format time for display
  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('hh:mm a').format(time);
  }

  // Get time until next Fajr
  String getTimeUntilFajr() {
    DateTime? nextFajr;
    final now = DateTime.now();

    // Check if we're before today's Fajr
    if (todayFajrTime != null && now.isBefore(todayFajrTime!)) {
      nextFajr = todayFajrTime;
    } else if (tomorrowFajrTime != null) {
      nextFajr = tomorrowFajrTime;
    }

    if (nextFajr == null) return 'Unknown';

    final difference = nextFajr.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }
}

class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    // Remove timezone info (e.g., "(+06)" from "05:30 (+06)")
    String cleanTime(String time) {
      return time.split(' ')[0];
    }

    return PrayerTimes(
      fajr: cleanTime(json['Fajr'] ?? '00:00'),
      sunrise: cleanTime(json['Sunrise'] ?? '00:00'),
      dhuhr: cleanTime(json['Dhuhr'] ?? '00:00'),
      asr: cleanTime(json['Asr'] ?? '00:00'),
      sunset: cleanTime(json['Sunset'] ?? '00:00'),
      maghrib: cleanTime(json['Maghrib'] ?? '00:00'),
      isha: cleanTime(json['Isha'] ?? '00:00'),
      imsak: cleanTime(json['Imsak'] ?? '00:00'),
      midnight: cleanTime(json['Midnight'] ?? '00:00'),
    );
  }
}