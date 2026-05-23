import 'package:aedes_alert_yungrai/features/map/domain/entities/map_area_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/place_entity.dart';

abstract class MapRepository {
  Future<List<MapAreaEntity>> getAllAreas();
  Future<List<PlaceEntity>> getAllPlaces();
}
