import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/repositories/ranking_repository_impl.dart';

class GetRankedAreasUseCase {
  const GetRankedAreasUseCase(this._repository);

  final RankingRepository _repository;

  Future<List<RankingAreaEntity>> execute({int limit = 20}) async {
    final areas = await _repository.getRankedAreas(limit: limit);

    // Deduplicate: keep only the highest riskScore entry per district.
    final Map<String, RankingAreaEntity> best = {};
    for (final area in areas) {
      final existing = best[area.district];
      if (existing == null || area.riskScore > existing.riskScore) {
        best[area.district] = area;
      }
    }

    // Re-sort by riskScore descending and return.
    return best.values.toList()
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));
  }
}

final getRankedAreasUseCaseProvider = Provider<GetRankedAreasUseCase>((ref) {
  return GetRankedAreasUseCase(ref.watch(rankingRepositoryProvider));
});