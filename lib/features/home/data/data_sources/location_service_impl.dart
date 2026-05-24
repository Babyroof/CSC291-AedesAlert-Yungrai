import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/location_service.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/location_entity.dart';

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => 'LocationServiceException: $message';
}

class LocationServiceImpl implements LocationService {
  @override
  Future<LocationEntity> getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationServiceException('Location permission denied');
    }
    final pos = await Geolocator.getCurrentPosition();
    return LocationEntity(latitude: pos.latitude, longitude: pos.longitude);
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationServiceImpl(),
);
