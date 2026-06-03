import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';

abstract class RankingRepository {
  Future<List<RankingAreaEntity>> getRankedAreas({int limit = 20});
  Stream<List<RankingAreaEntity>> watchRankedAreas({int limit = 20});
}
