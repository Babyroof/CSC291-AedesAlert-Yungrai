import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';

abstract class AreaRepository {
  Future<AreaModel?> getNearestArea(
    GeoPoint userLocation, {
    double radiusKm = 5.0,
  });

  /// Returns the single latest [AreaModel] for the given [district] name.
  /// Prefers a document where `isLatest == true`; falls back to the most
  /// recently [updatedAt] document when no `isLatest` flag is set.
  /// Returns null when no matching document exists.
  Future<AreaModel?> getLatestAreaByDistrict(String district);
}
