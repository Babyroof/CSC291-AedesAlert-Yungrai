import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/area_repository.dart';
import 'package:aedes_alert_yungrai/features/home/data/repositories/area_repository_impl.dart';

/// Returns the latest [AreaModel] for a given district name.
///
/// Prefers documents marked `isLatest == true`; falls back to the most
/// recently updated document when the flag is absent.
class GetLatestAreaForDistrictUseCase {
  const GetLatestAreaForDistrictUseCase(this._repository);

  final AreaRepository _repository;

  Future<AreaModel?> execute(String district) =>
      _repository.getLatestAreaByDistrict(district);
}

final getLatestAreaForDistrictUseCaseProvider =
    Provider<GetLatestAreaForDistrictUseCase>((ref) {
  return GetLatestAreaForDistrictUseCase(ref.watch(areaRepositoryProvider));
});