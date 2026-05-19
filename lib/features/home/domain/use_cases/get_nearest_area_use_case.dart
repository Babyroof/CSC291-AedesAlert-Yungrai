import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/area_repository.dart';
import 'package:aedes_alert_yungrai/features/home/data/repositories/area_repository_impl.dart';

class GetNearestAreaUseCase {
  const GetNearestAreaUseCase(this._repository);

  final AreaRepository _repository;

  Future<AreaModel?> execute(
    GeoPoint userLocation, {
    double radiusKm = 5.0,
  }) =>
      _repository.getNearestArea(userLocation, radiusKm: radiusKm);
}

final getNearestAreaUseCaseProvider = Provider<GetNearestAreaUseCase>((ref) {
  return GetNearestAreaUseCase(ref.watch(areaRepositoryProvider));
});
