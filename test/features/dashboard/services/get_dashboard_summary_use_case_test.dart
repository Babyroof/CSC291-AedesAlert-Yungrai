import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/monthly_risk_data_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_risk_counts_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_average_risk_score_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_monthly_trend_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_top_areas_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_dashboard_summary_use_case.dart';

import 'get_dashboard_summary_use_case_test.mocks.dart';

@GenerateMocks([
  GetRiskCountsUseCase,
  GetAverageRiskScoreUseCase,
  GetMonthlyTrendUseCase,
  GetTopAreasUseCase,
])
void main() {
  late MockGetRiskCountsUseCase mockGetRiskCounts;
  late MockGetAverageRiskScoreUseCase mockGetAverageScore;
  late MockGetMonthlyTrendUseCase mockGetMonthlyTrend;
  late MockGetTopAreasUseCase mockGetTopAreas;
  late GetDashboardSummaryUseCase useCase;

  setUp(() {
    mockGetRiskCounts = MockGetRiskCountsUseCase();
    mockGetAverageScore = MockGetAverageRiskScoreUseCase();
    mockGetMonthlyTrend = MockGetMonthlyTrendUseCase();
    mockGetTopAreas = MockGetTopAreasUseCase();

    useCase = GetDashboardSummaryUseCase(
      getRiskCounts: mockGetRiskCounts,
      getAverageScore: mockGetAverageScore,
      getMonthlyTrend: mockGetMonthlyTrend,
      getTopAreas: mockGetTopAreas,
    );
  });

  AreaModel fakeArea() => AreaModel(
        id: 'a1',
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

  void stubAllSuccess() {
    when(mockGetRiskCounts.execute()).thenAnswer((_) async =>
        const RiskCountModel(
          criticalCount: 1,
          highCount: 2,
          mediumCount: 3,
          lowCount: 4,
        ));
    when(mockGetAverageScore.execute()).thenAnswer((_) async => 55.0);
    when(mockGetMonthlyTrend.execute()).thenAnswer((_) async => [
          MonthlyRiskDataModel.fromBucket('2024-06', [55.0]),
        ]);
    when(mockGetTopAreas.execute(limit: anyNamed('limit')))
        .thenAnswer((_) async => [fakeArea()]);
  }

  test('returns assembled DashboardSummaryModel on success', () async {
    stubAllSuccess();
    final result = await useCase.execute();
    expect(result.riskCounts.totalCount, 10);
    expect(result.averageRiskScore, 55.0);
    expect(result.monthlyTrend.length, 1);
    expect(result.topFiveAreas.length, 1);
  });

  test('empty areas — all sub-use-cases return zeros/empty without crash',
      () async {
    when(mockGetRiskCounts.execute()).thenAnswer((_) async =>
        const RiskCountModel(
          criticalCount: 0,
          highCount: 0,
          mediumCount: 0,
          lowCount: 0,
        ));
    when(mockGetAverageScore.execute()).thenAnswer((_) async => 0.0);
    when(mockGetMonthlyTrend.execute()).thenAnswer((_) async => []);
    when(mockGetTopAreas.execute(limit: anyNamed('limit')))
        .thenAnswer((_) async => []);

    final result = await useCase.execute();
    expect(result.riskCounts.totalCount, 0);
    expect(result.averageRiskScore, 0.0);
    expect(result.monthlyTrend, isEmpty);
    expect(result.topFiveAreas, isEmpty);
  });

  test('propagates exception from any sub-use-case', () async {
    when(mockGetRiskCounts.execute()).thenThrow(Exception('Firestore error'));
    when(mockGetAverageScore.execute()).thenAnswer((_) async => 0.0);
    when(mockGetMonthlyTrend.execute()).thenAnswer((_) async => []);
    when(mockGetTopAreas.execute(limit: anyNamed('limit')))
        .thenAnswer((_) async => []);

    expect(() => useCase.execute(), throwsA(isA<Exception>()));
  });
}
