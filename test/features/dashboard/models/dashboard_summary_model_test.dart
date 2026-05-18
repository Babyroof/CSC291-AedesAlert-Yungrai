import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/home/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/models/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/models/monthly_risk_data_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/models/dashboard_summary_model.dart';

void main() {
  AreaModel fakeArea(String id) => AreaModel(
        id: id,
        subDistrict: 'S',
        district: 'D',
        province: 'P',
        location: const GeoPoint(13.7563, 100.5018),
        radius: 500,
        riskScore: 60.0,
        riskLevel: 'medium',
        reportedAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

  DashboardSummaryModel fakeSummary() => DashboardSummaryModel(
        riskCounts: const RiskCountModel(
          criticalCount: 1,
          highCount: 2,
          mediumCount: 3,
          lowCount: 4,
        ),
        averageRiskScore: 55.0,
        monthlyTrend: [
          MonthlyRiskDataModel.fromBucket('2024-06', [55.0]),
        ],
        topFiveAreas: [fakeArea('a1'), fakeArea('a2')],
      );

  test('constructs and holds all fields', () {
    final model = fakeSummary();
    expect(model.riskCounts.totalCount, 10);
    expect(model.averageRiskScore, 55.0);
    expect(model.monthlyTrend.length, 1);
    expect(model.topFiveAreas.length, 2);
  });

  test('copyWith replaces only specified fields', () {
    final original = fakeSummary();
    final updated = original.copyWith(averageRiskScore: 80.0);

    expect(updated.averageRiskScore, 80.0);
    expect(updated.riskCounts.totalCount, original.riskCounts.totalCount);
    expect(updated.topFiveAreas.length, original.topFiveAreas.length);
  });

  test('empty topFiveAreas is valid', () {
    final model = DashboardSummaryModel(
      riskCounts: const RiskCountModel(
        criticalCount: 0,
        highCount: 0,
        mediumCount: 0,
        lowCount: 0,
      ),
      averageRiskScore: 0.0,
      monthlyTrend: [],
      topFiveAreas: [],
    );
    expect(model.topFiveAreas, isEmpty);
    expect(model.monthlyTrend, isEmpty);
    expect(model.riskCounts.totalCount, 0);
  });
}
