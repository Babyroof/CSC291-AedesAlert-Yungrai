import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class GetRiskCountsUseCase {
  const GetRiskCountsUseCase(this._repository);

  final DashboardRepository _repository;

  /// Fix 3 & 5 — counts are based on the number of *distinct districts*
  /// at each risk level, not raw document count.
  ///
  /// When a district has multiple sub-district documents we take the
  /// riskLevel of the sub-district with the highest riskScore for that
  /// district (worst-case representative level).
  Future<RiskCountModel> execute() async {
    final areas = await _repository.getAllAreas();

    // Group areas by district → keep the highest-scored one per district.
    final Map<String, String> districtLevel = {};
    final Map<String, double> districtMaxScore = {};

    for (final area in areas) {
      final prev = districtMaxScore[area.district] ?? -1;
      if (area.riskScore > prev) {
        districtMaxScore[area.district] = area.riskScore;
        districtLevel[area.district] = area.riskLevel;
      }
    }

    int critical = 0, high = 0, medium = 0, low = 0;
    for (final level in districtLevel.values) {
      switch (level) {
        case 'critical':
          critical++;
        case 'high':
          high++;
        case 'medium':
          medium++;
        default:
          low++;
      }
    }

    return RiskCountModel(
      criticalCount: critical,
      highCount: high,
      mediumCount: medium,
      lowCount: low,
    );
  }
}

final getRiskCountsUseCaseProvider = Provider<GetRiskCountsUseCase>((ref) {
  return GetRiskCountsUseCase(ref.watch(dashboardRepositoryProvider));
});
