import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/place_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/repositories/map_repository.dart';
import 'package:aedes_alert_yungrai/features/map/data/repositories/map_repository_impl.dart';

class GetPlacesUseCase {
  const GetPlacesUseCase(this._repository);

  final MapRepository _repository;

  Future<List<PlaceEntity>> execute() => _repository.getAllPlaces();
}

final getPlacesUseCaseProvider = Provider<GetPlacesUseCase>((ref) {
  return GetPlacesUseCase(ref.watch(mapRepositoryProvider));
});
