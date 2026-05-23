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

    // Compute distance for each document and filter by radius
    final candidates =
        snapshot.docs
            .map((doc) {
              final location = doc.data()['location'] as GeoPoint;
              return (
                doc: doc,
                distance: GeoUtils.distanceInKm(userLocation, location),
              );
            })
            .where((item) => item.distance <= radiusKm)
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));

    if (candidates.isEmpty) return null;

    return AreaModel.fromFirestore(candidates.first.doc);
  }
}

final areaRepositoryProvider = Provider<AreaRepository>((ref) {
  return AreaRepositoryImpl(FirebaseFirestore.instance);
});
