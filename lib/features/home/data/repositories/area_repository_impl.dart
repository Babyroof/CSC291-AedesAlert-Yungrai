import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/core/utils/geo_utils.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/area_repository.dart';

class AreaRepositoryImpl implements AreaRepository {
  const AreaRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<AreaModel?> getNearestArea(
    GeoPoint userLocation, {
    double radiusKm = AppConstants.defaultGeoRadiusKm,
  }) async {
    final snapshot = await _firestore
        .collection(AppConstants.areasCollection)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final withDistance = snapshot.docs
        .where((doc) => doc.data()['location'] is GeoPoint)
        .map((doc) {
          final location = doc.data()['location'] as GeoPoint;
          return (
            doc: doc,
            distance: GeoUtils.distanceInKm(userLocation, location),
          );
        })
        .where((e) => e.distance <= radiusKm)
        .toList();

    if (withDistance.isEmpty) return null;

    withDistance.sort((a, b) => a.distance.compareTo(b.distance));
    return AreaModel.fromFirestore(withDistance.first.doc);
  }
}

final areaRepositoryProvider = Provider<AreaRepository>((ref) {
  return AreaRepositoryImpl(FirebaseFirestore.instance);
});
