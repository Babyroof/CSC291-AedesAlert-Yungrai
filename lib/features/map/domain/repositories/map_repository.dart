import 'package:aedes_alert_yungrai/features/map/domain/entities/map_area_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/place_entity.dart';

abstract class MapRepository {
  Stream<List<MapAreaEntity>> watchAllAreas();
  Future<List<PlaceEntity>> getAllPlaces();
}
