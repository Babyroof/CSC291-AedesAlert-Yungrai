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

  AreaModel makeArea(
    String id,
    double score, {
    String district = 'D',
    DateTime? updatedAt,
  }) => AreaModel(
    id: id,
    subDistrict: 'S',
    district: district,
    province: 'P',
    location: const GeoPoint(13.7563, 100.5018),
    radius: 500,
    riskScore: score,
    riskLevel: 'high',
    reportedAt: DateTime(2024, 1, 1),
    updatedAt: updatedAt ?? DateTime(2024, 6, 1),
  );

  test('empty collection returns empty list without crash', () async {
    when(mockRepo.getAllAreas()).thenAnswer((_) async => []);
    final result = await useCase.execute(limit: 5);
    expect(result, isEmpty);
  });

  test('returns areas from repository sorted by score descending', () async {
    when(mockRepo.getAllAreas()).thenAnswer(
      (_) async => [
        makeArea('a1', 90.0, district: 'A'),
        makeArea('a2', 80.0, district: 'B'),
      ],
    );
    final result = await useCase.execute(limit: 5);
    expect(result.length, 2);
    // First result should be the highest-scored district.
    expect(result.first.riskScore, 90.0);
  });

  test('passes limit to result — returns at most limit districts', () async {
    when(mockRepo.getAllAreas()).thenAnswer(
      (_) async => [
        makeArea('a1', 90.0, district: 'A'),
        makeArea('a2', 80.0, district: 'B'),
        makeArea('a3', 70.0, district: 'C'),
        makeArea('a4', 60.0, district: 'D'),
      ],
    );
    final result = await useCase.execute(limit: 2);
    expect(result.length, 2);
  });

  test(
    'null riskScore area (defaulted to 0.0) is returned without crash',
    () async {
      when(
        mockRepo.getAllAreas(),
      ).thenAnswer((_) async => [makeArea('nullArea', 0.0)]);
      final result = await useCase.execute(limit: 5);
      expect(result.first.riskScore, 0.0);
    },
  );
}
