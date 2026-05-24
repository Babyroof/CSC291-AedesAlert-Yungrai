import 'package:aedes_alert_yungrai/features/home/domain/entities/location_entity.dart';

abstract class LocationService {
  Future<LocationEntity> getCurrentLocation();
}
