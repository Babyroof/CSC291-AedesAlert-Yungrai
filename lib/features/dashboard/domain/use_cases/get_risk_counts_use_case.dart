import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class GetRiskCountsUseCase {
  const GetRiskCountsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<RiskCountModel> execute() async {
    final areas = await _repository.getAllAreas();
    int critical = 0, high = 0, medium = 0, low = 0;
    for (final area in areas) {
      switch (area.riskLevel) {
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
