import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/dashboard_repository_impl.dart';

class GetAverageRiskScoreUseCase {
  const GetAverageRiskScoreUseCase(this._repository);

  final DashboardRepository _repository;

  Future<double> execute() async {
    final areas = await _repository.getAllAreas();
    if (areas.isEmpty) return 0.0;
    final sum = areas.fold(0.0, (acc, a) => acc + a.riskScore);
    return sum / areas.length;
  }
}

final getAverageRiskScoreUseCaseProvider =
    Provider<GetAverageRiskScoreUseCase>((ref) {
  return GetAverageRiskScoreUseCase(ref.watch(dashboardRepositoryProvider));
});
