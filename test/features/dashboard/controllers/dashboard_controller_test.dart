import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/monthly_risk_data_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/dashboard_summary_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_dashboard_summary_use_case.dart';
import 'package:aedes_alert_yungrai/features/dashboard/presentation/controllers/dashboard_controller.dart';

import 'dashboard_controller_test.mocks.dart';

@GenerateMocks([GetDashboardSummaryUseCase])
void main() {
  late MockGetDashboardSummaryUseCase mockGetSummary;
  late DashboardController controller;

  setUp(() {
    mockGetSummary = MockGetDashboardSummaryUseCase();
    controller = DashboardController(mockGetSummary);
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
    topFiveAreas: [fakeArea()],
    selectedMonthKey: '2024-06',
  );

  test('initial state is loading', () {
    expect(controller.state.summary, isA<AsyncLoading>());
  });

  test('loadDashboard sets summary data on success', () async {
    when(
      mockGetSummary.execute(
        userLocation: anyNamed('userLocation'),
        selectedMonthKey: anyNamed('selectedMonthKey'),
      ),
    ).thenAnswer((_) async => fakeSummary());

    await controller.loadDashboard();

    expect(controller.state.summary.value?.averageRiskScore, 55.0);
    expect(controller.state.summary.value?.riskCounts.totalCount, 10);
  });

  test('loadDashboard sets error state on failure', () async {
    when(
      mockGetSummary.execute(
        userLocation: anyNamed('userLocation'),
        selectedMonthKey: anyNamed('selectedMonthKey'),
      ),
    ).thenThrow(Exception('Firestore error'));

    await controller.loadDashboard();

    expect(controller.state.summary, isA<AsyncError>());
  });

  test('empty areas — all zeros summary loads without crash', () async {
    when(
      mockGetSummary.execute(
        userLocation: anyNamed('userLocation'),
        selectedMonthKey: anyNamed('selectedMonthKey'),
      ),
    ).thenAnswer(
      (_) async => const DashboardSummaryModel(
        riskCounts: RiskCountModel(
          criticalCount: 0,
          highCount: 0,
          mediumCount: 0,
          lowCount: 0,
        ),
        averageRiskScore: 0.0,
        monthlyTrend: [],
        topFiveAreas: [],
        selectedMonthKey: null,
      ),
    );

    await controller.loadDashboard();

    expect(controller.state.summary.value?.riskCounts.totalCount, 0);
    expect(controller.state.summary.value?.averageRiskScore, 0.0);
    expect(controller.state.summary.value?.topFiveAreas, isEmpty);
  });

  test('refresh calls loadDashboard again', () async {
    when(
      mockGetSummary.execute(
        userLocation: anyNamed('userLocation'),
        selectedMonthKey: anyNamed('selectedMonthKey'),
      ),
    ).thenAnswer((_) async => fakeSummary());

    await controller.loadDashboard();
    await controller.refresh();

    verify(
      mockGetSummary.execute(
        userLocation: anyNamed('userLocation'),
        selectedMonthKey: anyNamed('selectedMonthKey'),
      ),
    ).called(2);
  });
}