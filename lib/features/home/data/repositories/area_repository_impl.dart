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
    // Fetch all area documents with no server-side filters so the caller can
    // do geo-distance filtering entirely client-side.  Avoids composite-index
    // requirements that may not yet be deployed.
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _firestore
          .collection(AppConstants.areasCollection)
          .get();
    } catch (_) {
      return null;
    }

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

  @override
  Future<AreaModel?> getLatestAreaByDistrict(String district) async {
    // Simple single query: filter by district, take the most-recent document.
    // No isLatest filter and no month/date filter — those rely on composite
    // indexes that may not exist yet and caused the method to return null even
    // when data was present.
    final snapshot = await _firestore
        .collection(AppConstants.areasCollection)
        .where('district', isEqualTo: district)
        .orderBy('reportedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return AreaModel.fromFirestore(snapshot.docs.first);
    }

    return null;
  }
}

final areaRepositoryProvider = Provider<AreaRepository>((ref) {
  return AreaRepositoryImpl(FirebaseFirestore.instance);
});
