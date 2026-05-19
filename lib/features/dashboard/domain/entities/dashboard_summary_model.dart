import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/monthly_risk_data_model.dart';

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.riskCounts,
    required this.averageRiskScore,
    required this.monthlyTrend,
    required this.topFiveAreas,
  });

  final RiskCountModel riskCounts;
  final double averageRiskScore;
  final List<MonthlyRiskDataModel> monthlyTrend;
  final List<AreaModel> topFiveAreas;

  DashboardSummaryModel copyWith({
    RiskCountModel? riskCounts,
    double? averageRiskScore,
    List<MonthlyRiskDataModel>? monthlyTrend,
    List<AreaModel>? topFiveAreas,
  }) {
    return DashboardSummaryModel(
      riskCounts: riskCounts ?? this.riskCounts,
      averageRiskScore: averageRiskScore ?? this.averageRiskScore,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      topFiveAreas: topFiveAreas ?? this.topFiveAreas,
    );
  }
}
