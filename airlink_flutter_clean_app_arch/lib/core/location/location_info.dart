import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

abstract class LocationInfo {
  /// Checks if the device location service is enabled
  Future<bool> get isEnabled;

  /// Returns the current location
  Future<LocationResult?> getLocation();
}

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
}

class LocationInfoImpl implements LocationInfo {
  final Location _location = Location();

  @override
  Future<bool> get isEnabled => _location.serviceEnabled();

  @override
  Future<LocationResult?> getLocation() async {
    PermissionStatus permissionGranted;
    LocationData? locationData;
    bool serviceEnabled;

    // Check if location services are enabled
    serviceEnabled = await isEnabled;
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null; // Location services are not enabled
      }
    }

    // Check and request location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null; // Location permission not granted
      }
    }

    // Get the current location
    try {
      locationData = await _location.getLocation();
      return LocationResult(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          accuracy: locationData.accuracy!);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      return null;
    }
  }
}
