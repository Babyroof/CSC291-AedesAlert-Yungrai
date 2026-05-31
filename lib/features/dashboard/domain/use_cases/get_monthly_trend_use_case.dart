import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/utils/date_formatter.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/monthly_risk_data_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class GetMonthlyTrendUseCase {
  const GetMonthlyTrendUseCase(this._repository);

  final DashboardRepository _repository;

  Future<List<MonthlyRiskDataModel>> execute() async {
    final areas = await _repository.getAllAreas();
    final Map<String, List<double>> buckets = {};

    for (final area in areas) {
      final key = DateFormatter.toMonthKey(area.updatedAt);
      buckets.putIfAbsent(key, () => []).add(area.riskScore);
    }

    return buckets.entries
        .map((e) => MonthlyRiskDataModel.fromBucket(e.key, e.value))
        .toList()
      ..sort((a, b) => a.monthKey.compareTo(b.monthKey));
  }
}

final getMonthlyTrendUseCaseProvider = Provider<GetMonthlyTrendUseCase>((ref) {
  return GetMonthlyTrendUseCase(ref.watch(dashboardRepositoryProvider));
});
