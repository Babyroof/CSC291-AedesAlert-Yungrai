import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/dashboard_summary_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/monthly_risk_data_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_risk_counts_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_average_risk_score_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_monthly_trend_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_top_areas_use_case.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase({
    required this.getRiskCounts,
    required this.getAverageScore,
    required this.getMonthlyTrend,
    required this.getTopAreas,
  });

  final GetRiskCountsUseCase getRiskCounts;
  final GetAverageRiskScoreUseCase getAverageScore;
  final GetMonthlyTrendUseCase getMonthlyTrend;
  final GetTopAreasUseCase getTopAreas;

  Future<DashboardSummaryModel> execute() async {
    final results = await Future.wait<dynamic>([
      getRiskCounts.execute(),
      getAverageScore.execute(),
      getMonthlyTrend.execute(),
      getTopAreas.execute(limit: 5),
    ]);

    return DashboardSummaryModel(
      riskCounts: results[0] as RiskCountModel,
      averageRiskScore: results[1] as double,
      monthlyTrend: results[2] as List<MonthlyRiskDataModel>,
      topFiveAreas: results[3] as List<AreaModel>,
    );
  }
}

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>(
  (ref) {
    return GetDashboardSummaryUseCase(
      getRiskCounts: ref.watch(getRiskCountsUseCaseProvider),
      getAverageScore: ref.watch(getAverageRiskScoreUseCaseProvider),
      getMonthlyTrend: ref.watch(getMonthlyTrendUseCaseProvider),
      getTopAreas: ref.watch(getTopAreasUseCaseProvider),
    );
  },
);
