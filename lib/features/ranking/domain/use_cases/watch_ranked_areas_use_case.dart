import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/repositories/ranking_repository_impl.dart';

class WatchRankedAreasUseCase {
  const WatchRankedAreasUseCase(this._repository);
  final RankingRepository _repository;

  Stream<List<RankingAreaEntity>> watch({int limit = 20}) =>
      _repository.watchRankedAreas(limit: limit);
}

final watchRankedAreasUseCaseProvider = Provider<WatchRankedAreasUseCase>((
  ref,
) {
  return WatchRankedAreasUseCase(ref.watch(rankingRepositoryProvider));
});
