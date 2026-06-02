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

  /// Creates a [MonthlyRiskDataModel] from a pre-computed two-step district
  /// average ([avg]) so the caller is not forced to pass raw score lists.
  /// [areaCount] is the total number of area documents in this month.
  factory MonthlyRiskDataModel.fromComputedAvg(
    String monthKey,
    double avg,
    int areaCount,
  ) {
    final parts = monthKey.split('-');
    final month = int.parse(parts[1]);
    return MonthlyRiskDataModel(
      monthKey: monthKey,
      monthLabel: DateFormatter.monthAbbreviation(month),
      avgRiskScore: double.parse(avg.toStringAsFixed(1)),
      areaCount: areaCount,
    );
  }
}
