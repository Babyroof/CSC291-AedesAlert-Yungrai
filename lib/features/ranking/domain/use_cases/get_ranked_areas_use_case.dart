import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/repositories/ranking_repository_impl.dart';

class GetRankedAreasUseCase {
  const GetRankedAreasUseCase(this._repository);

  final RankingRepository _repository;

  Future<List<RankingAreaEntity>> execute({int limit = 20}) =>
      _repository.getRankedAreas(limit: limit);
}

final getRankedAreasUseCaseProvider = Provider<GetRankedAreasUseCase>((ref) {
  return GetRankedAreasUseCase(ref.watch(rankingRepositoryProvider));
});
