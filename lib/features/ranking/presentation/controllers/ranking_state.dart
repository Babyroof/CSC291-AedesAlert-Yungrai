import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';

class RankingState {
  const RankingState({required this.areas});

  final AsyncValue<List<RankingAreaEntity>> areas;

  factory RankingState.initial() =>
      const RankingState(areas: AsyncValue.loading());

  RankingState copyWith({AsyncValue<List<RankingAreaEntity>>? areas}) =>
      RankingState(areas: areas ?? this.areas);
}
