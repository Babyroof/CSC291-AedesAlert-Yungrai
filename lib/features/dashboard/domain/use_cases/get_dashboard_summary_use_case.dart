import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/dashboard_summary_model.dart';
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

  /// [userLocation] — forwarded to [GetMonthlyTrendUseCase] for Fix 4a.
  /// [userDistrict] — forwarded to [GetAverageRiskScoreUseCase] and
  ///   [GetMonthlyTrendUseCase] so both show data for the user's district only.
  /// [selectedMonthKey] — forwarded to [GetTopAreasUseCase] and
  ///   [GetRiskCountsUseCase] for Fix 3 & Fix 6;
  ///   when null the most-recent month is used automatically.
  Future<DashboardSummaryModel> execute({
    GeoPoint? userLocation,
    String? userDistrict,
    String? selectedMonthKey,
  }) async {
    // Monthly trend must run first so we know which months exist and can
    // use the most-recent month as the default for top-areas when the
    // caller has not yet specified one.
    final trend = await getMonthlyTrend.execute(
      userLocation: userLocation,
      userDistrict: userDistrict,
    );

    // Use caller-supplied month or fall back to the most recent real month.
    final effectiveMonthKey =
        selectedMonthKey ?? (trend.isNotEmpty ? trend.last.monthKey : null);

    final results = await Future.wait<dynamic>([
      getRiskCounts.execute(selectedMonthKey: effectiveMonthKey),
      getAverageScore.execute(
        userDistrict: userDistrict,
        selectedMonthKey: effectiveMonthKey,
      ),
      getTopAreas.execute(limit: 5, monthKey: effectiveMonthKey),
    ]);

    return DashboardSummaryModel(
      riskCounts: results[0] as RiskCountModel,
      averageRiskScore: results[1] as double,
      monthlyTrend: trend,
      topFiveAreas: results[2] as List<AreaModel>,
      selectedMonthKey: effectiveMonthKey,
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
