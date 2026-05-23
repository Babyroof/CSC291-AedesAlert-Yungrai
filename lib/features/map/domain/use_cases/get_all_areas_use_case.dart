import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/map_area_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/repositories/map_repository.dart';
import 'package:aedes_alert_yungrai/features/map/data/repositories/map_repository_impl.dart';

class GetAllAreasUseCase {
  const GetAllAreasUseCase(this._repository);

  final MapRepository _repository;

  Future<List<MapAreaEntity>> execute() => _repository.getAllAreas();
}

final getAllAreasUseCaseProvider = Provider<GetAllAreasUseCase>((ref) {
  return GetAllAreasUseCase(ref.watch(mapRepositoryProvider));
});
