import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/map/data/models/place_model.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/map_area_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/place_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  const MapRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<MapAreaEntity>> getAllAreas() async {
    final snapshot = await _firestore
        .collection(AppConstants.areasCollection)
        .get();
    return snapshot.docs.map((doc) {
      final m = AreaModel.fromFirestore(doc);
      return MapAreaEntity(
        id: m.id,
        subDistrict: m.subDistrict,
        district: m.district,
        province: m.province,
        lat: m.location.latitude,
        lng: m.location.longitude,
        radius: m.radius,
        riskScore: m.riskScore,
        riskLevel: m.riskLevel,
      );
    }).toList();
  }

  @override
  Future<List<PlaceEntity>> getAllPlaces() async {
    final snapshot = await _firestore
        .collection(AppConstants.placesCollection)
        .get();
    return snapshot.docs
        .map((doc) => PlaceModel.fromFirestore(doc).toEntity())
        .toList();
  }
}

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl(FirebaseFirestore.instance);
});
