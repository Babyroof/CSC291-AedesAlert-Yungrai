import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';

abstract class AreaRepository {
  Future<AreaModel?> getNearestArea(
    GeoPoint userLocation, {
    double radiusKm = 5.0,
  });
}
