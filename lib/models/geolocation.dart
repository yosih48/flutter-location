import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class StreamLocationService {

  static const LocationSettings _locationSettings =
      LocationSettings(distanceFilter: 1);
  static bool _isLocationGranted = true;

  static Stream<Position>? get onLocationChanged {
    if (_isLocationGranted) {
        print('_isLocationGranted: ${_isLocationGranted}');
        print('class StreamLocationService');
      return Geolocator.getPositionStream(locationSettings: _locationSettings);
    }
      print('_isLocationGranted: ${_isLocationGranted}');
    return null;
  }

  static Future<bool> askLocationPermission() async {
    _isLocationGranted = await Permission.location.request().isGranted;
    return _isLocationGranted;
  }
}
