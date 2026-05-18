import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/get_risk_counts_use_case.dart';

import 'get_risk_counts_use_case_test.mocks.dart';

@GenerateMocks([DashboardRepository])
void main() {
  late MockDashboardRepository mockRepo;
  late GetRiskCountsUseCase useCase;

  setUp(() {
    mockRepo = MockDashboardRepository();
    useCase = GetRiskCountsUseCase(mockRepo);
  });

  AreaModel makeArea(String level, {double score = 50.0}) => AreaModel(
        id: level,
        subDistrict: 'S',
        district: 'D',
        province: 'P',
        location: const GeoPoint(13.7563, 100.5018),
        radius: 500,
        riskScore: score,
        riskLevel: level,
        reportedAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

  test('empty collection returns all zeros without crash', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => []);
    final result = await useCase.execute();
    expect(result.criticalCount, 0);
    expect(result.highCount, 0);
    expect(result.mediumCount, 0);
    expect(result.lowCount, 0);
    expect(result.totalCount, 0);
  });

  test('counts each risk level correctly', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [
          makeArea('critical'),
          makeArea('critical'),
          makeArea('high'),
          makeArea('medium'),
          makeArea('medium'),
          makeArea('medium'),
          makeArea('low'),
        ]);

    final result = await useCase.execute();
    expect(result.criticalCount, 2);
    expect(result.highCount, 1);
    expect(result.mediumCount, 3);
    expect(result.lowCount, 1);
    expect(result.totalCount, 7);
  });

  test('null riskScore area does not affect level count', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [
          makeArea('low', score: 0.0),
        ]);
    final result = await useCase.execute();
    expect(result.lowCount, 1);
  });

  test('unknown riskLevel falls into low bucket', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [
          makeArea('unknown'),
        ]);
    final result = await useCase.execute();
    expect(result.lowCount, 1);
  });
}
