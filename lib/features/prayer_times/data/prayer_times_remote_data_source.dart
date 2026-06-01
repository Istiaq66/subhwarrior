import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/prayer_times.dart';

/// Talks to the Aladhan REST API. The only place that knows the endpoint
/// shape and query parameters. Uses HTTPS (IMPROVEMENT_PLAN D3).
class PrayerTimesRemoteDataSource {
  final http.Client _client;

  PrayerTimesRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  static const _base = 'https://api.aladhan.com/v1';

  Future<PrayerTimes> fetchByCoordinates({
    required DateTime date,
    required double latitude,
    required double longitude,
    required int method,
    required int school,
  }) async {
    final dateStr = _dateStr(date);
    final url = Uri.parse(
      '$_base/timings/$dateStr'
      '?latitude=$latitude&longitude=$longitude&method=$method&school=$school',
    );
    return _get(url);
  }

  Future<PrayerTimes> fetchByCity({
    required DateTime date,
    required String city,
    required String country,
    required int method,
    required int school,
  }) async {
    final dateStr = _dateStr(date);
    final url = Uri.parse(
      '$_base/timingsByCity/$dateStr'
      '?city=$city&country=$country&method=$method&school=$school',
    );
    return _get(url);
  }

  String _dateStr(DateTime date) => '${date.day}-${date.month}-${date.year}';

  Future<PrayerTimes> _get(Uri url) async {
    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw Exception(
          'Aladhan request failed (${response.statusCode}) for $url');
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final timings = data['data']?['timings'] as Map<String, dynamic>?;
    if (timings == null) {
      throw Exception('Aladhan response missing timings for $url');
    }
    return PrayerTimes.fromJson(timings);
  }
}
