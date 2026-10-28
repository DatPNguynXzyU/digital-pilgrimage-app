import 'package:geolocator/geolocator.dart';

import '../models/temple.dart';

enum NearbyLocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class NearbyLocationException implements Exception {
  const NearbyLocationException(this.failure);

  final NearbyLocationFailure failure;
}

class NearbyTemples {
  static double? distance(Temple temple, double latitude, double longitude) {
    final lat = temple.latitude;
    final lon = temple.longitude;
    if (lat == null ||
        lon == null ||
        !lat.isFinite ||
        !lon.isFinite ||
        lat.abs() > 90 ||
        lon.abs() > 180) {
      return null;
    }
    return Geolocator.distanceBetween(latitude, longitude, lat, lon);
  }

  static List<Temple> sorted(List<Temple> temples, double lat, double lon) {
    return [...temples]..sort((a, b) {
      final first = distance(a, lat, lon) ?? double.infinity;
      final second = distance(b, lat, lon) ?? double.infinity;
      final comparison = first.compareTo(second);
      return comparison != 0 ? comparison : a.name.compareTo(b.name);
    });
  }

  static Future<Position> locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const NearbyLocationException(
        NearbyLocationFailure.serviceDisabled,
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const NearbyLocationException(
        NearbyLocationFailure.permissionDeniedForever,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const NearbyLocationException(
        NearbyLocationFailure.permissionDenied,
      );
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }
}
