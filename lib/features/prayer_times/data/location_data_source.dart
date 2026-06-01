import 'package:geolocator/geolocator.dart';

/// A geographic coordinate. Keeps the Geolocator [Position] type from leaking
/// past the data layer.
typedef Coordinates = ({double latitude, double longitude});

/// Wraps the device location services (Geolocator). The only place that knows
/// about permissions and the platform location API.
class LocationDataSource {
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

    final position = await Geolocator.getCurrentPosition();
    return (latitude: position.latitude, longitude: position.longitude);
  }
}
