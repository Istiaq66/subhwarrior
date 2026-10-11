import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// A geographic coordinate. Keeps the Geolocator [Position] type from leaking
/// past the data layer.
typedef Coordinates = ({double latitude, double longitude});

/// Wraps the device location services (Geolocator). The only place that knows
/// about permissions and the platform location API.
class LocationDataSource {
  /// How long to wait for a fresh fix before settling for the last known one.
  /// Without a limit the request waits for satellites indefinitely — indoors,
  /// or when the device's cached fix is too old to be handed out, the
  /// "getting location" spinner never stopped.
  static const fixTimeLimit = Duration(seconds: 15);

  /// The device's position, assuming access is already granted: a fresh fix
  /// when one arrives within [fixTimeLimit], else the last known position.
  ///
  /// Medium accuracy (Wi-Fi and cell, ~100 m) is far finer than prayer times
  /// need and, unlike high accuracy, does not wait for GPS. Throws
  /// [TimeoutException] when there is neither a fix nor a last position.
  static Future<Coordinates> deviceFix() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: fixTimeLimit,
        ),
      );
    } on TimeoutException {
      position = await Geolocator.getLastKnownPosition() ??
          (throw TimeoutException(
              'No location fix within ${fixTimeLimit.inSeconds}s'));
    }
    return (latitude: position.latitude, longitude: position.longitude);
  }

  Future<Coordinates> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return deviceFix();
  }
}
