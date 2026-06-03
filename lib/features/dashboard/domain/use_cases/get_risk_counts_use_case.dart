import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/utils/date_formatter.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class GetRiskCountsUseCase {
  const GetRiskCountsUseCase(this._repository);

  final DashboardRepository _repository;

  /// Fix 3 — counts are based on the number of *distinct districts*
  /// at each risk level, not raw document count.
  ///
  /// When a district has multiple sub-district documents we take the
  /// riskLevel of the sub-district with the highest riskScore for that
  /// district (worst-case representative level).
  ///
  /// [selectedMonthKey] — optional "YYYY-MM" string.  When supplied, only
  /// areas whose [reportedAt] falls in that month are counted.
  /// When null the most-recent available month is used (i.e. all areas whose
  /// [reportedAt] matches the latest month found in the data).
  Future<RiskCountModel> execute({String? selectedMonthKey}) async {
    final areas = await _repository.getAllAreas();

    // Determine effective month key
    String? effectiveKey = selectedMonthKey;
    if (effectiveKey == null && areas.isNotEmpty) {
      // Use the most recent month present in the data.
      final keys = areas.map((a) => DateFormatter.toMonthKey(a.reportedAt));
      effectiveKey = keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    }

    // Filter areas to the selected month.
    final filtered = effectiveKey == null
        ? areas
        : areas
            .where((a) =>
                DateFormatter.toMonthKey(a.reportedAt) == effectiveKey)
            .toList();

    // Group areas by district → keep the highest-scored one per district.
    final Map<String, String> districtLevel = {};
    final Map<String, double> districtMaxScore = {};

    for (final area in filtered) {
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