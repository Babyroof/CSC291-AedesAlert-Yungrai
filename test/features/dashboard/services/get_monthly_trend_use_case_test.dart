import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/get_monthly_trend_use_case.dart';

import 'get_monthly_trend_use_case_test.mocks.dart';

@GenerateMocks([DashboardRepository])
void main() {
  late MockDashboardRepository mockRepo;
  late GetMonthlyTrendUseCase useCase;

  setUp(() {
    mockRepo = MockDashboardRepository();
    useCase = GetMonthlyTrendUseCase(mockRepo);
  });

  AreaModel makeArea(double score, DateTime updatedAt) => AreaModel(
        id: 'a',
        subDistrict: 'S',
        district: 'D',
        province: 'P',
        location: const GeoPoint(13.7563, 100.5018),
        radius: 500,
        riskScore: score,
        riskLevel: 'medium',
        reportedAt: DateTime(2024, 1, 1),
        updatedAt: updatedAt,
      );

  test('empty collection returns empty list without crash', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => []);
    final result = await useCase.execute();
    expect(result, isEmpty);
  });

  test('single area produces one bucket', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [
          makeArea(70.0, DateTime(2024, 6, 15)),
        ]);
    final result = await useCase.execute();
    expect(result.length, 1);
    expect(result.first.monthKey, '2024-06');
    expect(result.first.avgRiskScore, 70.0);
  });

  test('areas in same month are grouped into one bucket', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [
          makeArea(60.0, DateTime(2024, 6, 1)),
          makeArea(80.0, DateTime(2024, 6, 20)),
        ]);
    final result = await useCase.execute();
    expect(result.length, 1);
    expect(result.first.avgRiskScore, 70.0);
    expect(result.first.areaCount, 2);
  });

  test('areas in different months produce separate sorted buckets', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [
          makeArea(50.0, DateTime(2024, 8, 1)),
          makeArea(90.0, DateTime(2024, 6, 1)),
          makeArea(70.0, DateTime(2024, 7, 1)),
        ]);
    final result = await useCase.execute();
    expect(result.length, 3);
    expect(result[0].monthKey, '2024-06');
    expect(result[1].monthKey, '2024-07');
    expect(result[2].monthKey, '2024-08');
  });

  test('null riskScore (defaulted to 0.0) does not crash monthly trend', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [
          makeArea(0.0, DateTime(2024, 6, 1)),
        ]);
    final result = await useCase.execute();
    expect(result.first.avgRiskScore, 0.0);
  });
}
