import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_average_risk_score_use_case.dart';

import 'get_average_risk_score_use_case_test.mocks.dart';

@GenerateMocks([DashboardRepository])
void main() {
  late MockDashboardRepository mockRepo;
  late GetAverageRiskScoreUseCase useCase;

  setUp(() {
    mockRepo = MockDashboardRepository();
    useCase = GetAverageRiskScoreUseCase(mockRepo);
  });

  AreaModel makeArea(double score) => AreaModel(
    id: 'a',
    subDistrict: 'S',
    district: 'D',
    province: 'P',
    location: const GeoPoint(13.7563, 100.5018),
    radius: 500,
    riskScore: score,
    riskLevel: 'medium',
    reportedAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 6, 1),
  );

  test('empty collection returns 0.0 without crash', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => []);
    final result = await useCase.execute();
    expect(result, 0.0);
  });

  test('single area returns its own score', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => [makeArea(70.0)]);
    final result = await useCase.execute();
    expect(result, 70.0);
  });

  test('multiple areas return correct average', () async {
    when(mockRepo.getAllAreas()).thenAnswer(
      (_) async => [makeArea(60.0), makeArea(80.0), makeArea(100.0)],
    );
    final result = await useCase.execute();
    expect(result, closeTo(80.0, 0.001));
  });

  test(
    'null riskScore area uses 0.0 in average (defaulted by model)',
    () async {
      when(
        mockRepo.getAllAreas(),
      ).thenAnswer((_) async => [makeArea(0.0), makeArea(100.0)]);
      final result = await useCase.execute();
      expect(result, closeTo(50.0, 0.001));
    },
  );
}
