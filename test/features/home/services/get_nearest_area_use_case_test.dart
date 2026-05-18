import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/services/area_repository.dart';
import 'package:aedes_alert_yungrai/features/home/services/get_nearest_area_use_case.dart';

import 'get_nearest_area_use_case_test.mocks.dart';

@GenerateMocks([AreaRepository])
void main() {
  late MockAreaRepository mockRepo;
  late GetNearestAreaUseCase useCase;

  setUp(() {
    mockRepo = MockAreaRepository();
    useCase = GetNearestAreaUseCase(mockRepo);
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

  test('returns area from repository', () async {
    when(mockRepo.getNearestArea(any, radiusKm: anyNamed('radiusKm')))
        .thenAnswer((_) async => fakeArea());

    final result = await useCase.execute(const GeoPoint(13.7563, 100.5018));
    expect(result, isNotNull);
    expect(result!.id, 'a1');
  });

  test('returns null when no area is within radius (empty collection)', () async {
    when(mockRepo.getNearestArea(any, radiusKm: anyNamed('radiusKm')))
        .thenAnswer((_) async => null);

    final result = await useCase.execute(const GeoPoint(13.7563, 100.5018));
    expect(result, isNull);
  });

  test('location permission denied — returns null gracefully', () async {
    when(mockRepo.getNearestArea(any, radiusKm: anyNamed('radiusKm')))
        .thenAnswer((_) async => null);

    // Simulates caller passing a null-equivalent location after permission denial
    final result = await useCase.execute(
      const GeoPoint(0.0, 0.0),
      radiusKm: 0.0,
    );
    expect(result, isNull);
  });

  test('propagates repository exception', () async {
    when(mockRepo.getNearestArea(any, radiusKm: anyNamed('radiusKm')))
        .thenThrow(Exception('Firestore error'));

    expect(
      () => useCase.execute(const GeoPoint(13.7563, 100.5018)),
      throwsA(isA<Exception>()),
    );
  });
}
