import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_risk_counts_use_case.dart';

import 'get_risk_counts_use_case_test.mocks.dart';

@GenerateMocks([DashboardRepository])
void main() {
  late MockDashboardRepository mockRepo;
  late GetRiskCountsUseCase useCase;

  setUp(() {
    mockRepo = MockDashboardRepository();
    useCase = GetRiskCountsUseCase(mockRepo);
  });

  // Build an area with a unique district name per call so deduplication does
  // not collapse distinct entries.
  AreaModel makeArea(String level, String district, {double score = 50.0}) =>
      AreaModel(
        id: '$level-$district',
        subDistrict: 'S',
        district: district,
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

  test('counts each risk level correctly (one district per level)', () async {
    // Use distinct district names so each is counted separately.
    when(mockRepo.getAllAreas()).thenAnswer(
      (_) async => [
        makeArea('critical', 'D1'),
        makeArea('critical', 'D2'),
        makeArea('high', 'D3'),
        makeArea('medium', 'D4'),
        makeArea('medium', 'D5'),
        makeArea('medium', 'D6'),
        makeArea('low', 'D7'),
      ],
    );

    final result = await useCase.execute();
    expect(result.criticalCount, 2);
    expect(result.highCount, 1);
    expect(result.mediumCount, 3);
    expect(result.lowCount, 1);
    expect(result.totalCount, 7);
  });

  test('null riskScore area does not affect level count', () async {
    when(
      mockRepo.getAllAreas(),
    ).thenAnswer((_) async => [makeArea('low', 'D1', score: 0.0)]);
    final result = await useCase.execute();
    expect(result.lowCount, 1);
  });

  test('unknown riskLevel falls into low bucket', () async {
    when(
      mockRepo.getAllAreas(),
    ).thenAnswer((_) async => [makeArea('unknown', 'D1')]);
    final result = await useCase.execute();
    expect(result.lowCount, 1);
  });

  test(
    'multiple docs for same district — only highest-scored one counts',
    () async {
      // District "D1" has two docs: one critical (score 90), one medium (score 30).
      // Should count as 1 critical (highest score wins).
      when(mockRepo.getAllAreas()).thenAnswer(
        (_) async => [
          makeArea('critical', 'D1', score: 90.0),
          makeArea('medium', 'D1', score: 30.0),
        ],
      );

      final result = await useCase.execute();
      expect(result.criticalCount, 1);
      expect(result.mediumCount, 0);
      expect(result.totalCount, 1);
    },
  );
}
