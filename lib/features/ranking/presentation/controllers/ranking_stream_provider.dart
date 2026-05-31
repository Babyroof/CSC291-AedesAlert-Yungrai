import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/use_cases/watch_ranked_areas_use_case.dart';

final rankedAreasStreamProvider = StreamProvider<List<RankingAreaEntity>>((ref) {
  return ref.watch(watchRankedAreasUseCaseProvider).watch();
});