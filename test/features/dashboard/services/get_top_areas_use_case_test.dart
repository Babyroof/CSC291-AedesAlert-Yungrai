import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_top_areas_use_case.dart';

import 'get_top_areas_use_case_test.mocks.dart';

@GenerateMocks([DashboardRepository])
void main() {
  late MockDashboardRepository mockRepo;
  late GetTopAreasUseCase useCase;

  setUp(() {
    mockRepo = MockDashboardRepository();
    useCase = GetTopAreasUseCase(mockRepo);
  });

  AreaModel makeArea(String id, double score) => AreaModel(
        id: id,
        subDistrict: 'S',
        district: 'D',
        province: 'P',
        location: const GeoPoint(13.7563, 100.5018),
        radius: 500,
        riskScore: score,
        riskLevel: 'high',
        reportedAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

  test('empty collection returns empty list without crash', () async {
    when(mockRepo.getTopAreasByRisk(limit: anyNamed('limit')))
        .thenAnswer((_) async => []);
    final result = await useCase.execute(limit: 5);
    expect(result, isEmpty);
  });

  test('returns areas from repository', () async {
    when(mockRepo.getTopAreasByRisk(limit: anyNamed('limit')))
        .thenAnswer((_) async => [
              makeArea('a1', 90.0),
              makeArea('a2', 80.0),
            ]);
    final result = await useCase.execute(limit: 5);
    expect(result.length, 2);
    expect(result.first.id, 'a1');
  });

  test('passes limit to repository', () async {
    when(mockRepo.getTopAreasByRisk(limit: anyNamed('limit')))
        .thenAnswer((_) async => []);
    await useCase.execute(limit: 3);
    verify(mockRepo.getTopAreasByRisk(limit: 3)).called(1);
  });

  test('null riskScore area (defaulted to 0.0) is returned without crash',
      () async {
    when(mockRepo.getTopAreasByRisk(limit: anyNamed('limit')))
        .thenAnswer((_) async => [makeArea('nullArea', 0.0)]);
    final result = await useCase.execute(limit: 5);
    expect(result.first.riskScore, 0.0);
  });
}
