import 'package:aedes_alert_yungrai/core/utils/date_formatter.dart';

class MonthlyRiskDataModel {
  const MonthlyRiskDataModel({
    required this.monthKey,
    required this.monthLabel,
    required this.avgRiskScore,
    required this.areaCount,
  });

  final String monthKey;
  final String monthLabel;
  final double avgRiskScore;
  final int areaCount;

  factory MonthlyRiskDataModel.fromBucket(
    String monthKey,
    List<double> scores,
  ) {
    final parts = monthKey.split('-');
    final month = int.parse(parts[1]);
    final avg = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a + b) / scores.length;
    return MonthlyRiskDataModel(
      monthKey: monthKey,
      monthLabel: DateFormatter.monthAbbreviation(month),
      avgRiskScore: avg,
      areaCount: scores.length,
    );
  }
}
