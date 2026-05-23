import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/use_cases/get_ranked_areas_use_case.dart';
import 'package:aedes_alert_yungrai/features/ranking/presentation/controllers/ranking_state.dart';

class RankingController extends StateNotifier<RankingState> {
  RankingController({required GetRankedAreasUseCase getRankedAreas})
      : _getRankedAreas = getRankedAreas,
        super(RankingState.initial());

  final GetRankedAreasUseCase _getRankedAreas;

  Future<void> loadRanking({int limit = 20}) async {
    state = RankingState.initial();
    try {
      final areas = await _getRankedAreas.execute(limit: limit);
      state = RankingState(areas: AsyncValue.data(areas));
    } catch (e, st) {
      state = RankingState(areas: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() => loadRanking();
}

final rankingControllerProvider =
    StateNotifierProvider<RankingController, RankingState>((ref) {
  return RankingController(
    getRankedAreas: ref.watch(getRankedAreasUseCaseProvider),
  );
});
