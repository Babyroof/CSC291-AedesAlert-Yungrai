import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/area_repository.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_latest_area_for_district_use_case.dart';

// ---------------------------------------------------------------------------
// Manual fake repository — no build_runner / @GenerateMocks needed.
// ---------------------------------------------------------------------------

class FakeAreaRepository implements AreaRepository {
  /// Controls what [getLatestAreaByDistrict] returns.
  AreaModel? latestAreaToReturn;

  /// Captured district argument from the last [getLatestAreaByDistrict] call.
  String? capturedDistrict;

  @override
  Future<AreaModel?> getNearestArea(
    GeoPoint userLocation, {
    double radiusKm = 5.0,
  }) async => null;

  @override
  Future<AreaModel?> getLatestAreaByDistrict(String district) async {
    capturedDistrict = district;
    return latestAreaToReturn;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AreaModel _fakeArea({
  String id = 'area-1',
  String district = 'Lat Krabang',
  double riskScore = 65.0,
  String riskLevel = 'high',
  DateTime? updatedAt,
}) => AreaModel(
  id: id,
  subDistrict: 'Sub',
  district: district,
  province: 'Bangkok',
  location: const GeoPoint(13.7563, 100.5018),
  radius: 500,
  riskScore: riskScore,
  riskLevel: riskLevel,
  reportedAt: DateTime(2024, 1, 1),
  updatedAt: updatedAt ?? DateTime(2024, 6, 1),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeAreaRepository fakeRepo;
  late GetLatestAreaForDistrictUseCase useCase;

  setUp(() {
    fakeRepo = FakeAreaRepository();
    useCase = GetLatestAreaForDistrictUseCase(fakeRepo);
  });

  // ── Test 1 ──────────────────────────────────────────────────────────────
  test('returns area with isLatest == true when field exists', () async {
    // The repository is expected to prefer isLatest==true documents.
    // Here we verify the use case forwards to the repository and returns
    // the area it provides (the "isLatest" filtering is the repo's job).
    final latest = _fakeArea(
      id: 'latest-doc',
      district: 'Nong Chok',
      riskScore: 88.0,
      riskLevel: 'critical',
      updatedAt: DateTime(2024, 6, 15),
    );
    fakeRepo.latestAreaToReturn = latest;

    final result = await useCase.execute('Nong Chok');

    expect(result, isNotNull);
    expect(result!.id, 'latest-doc');
    expect(result.riskScore, 88.0);
    expect(result.riskLevel, 'critical');
  });

  // ── Test 2 ──────────────────────────────────────────────────────────────
  test('falls back to most recent updatedAt when no isLatest field', () async {
    // The repository falls back to ordering by updatedAt when isLatest yields
    // no results.  Here the fake returns the most-recent document.
    final recent = _fakeArea(
      id: 'recent-doc',
      district: 'Min Buri',
      riskScore: 72.5,
      riskLevel: 'high',
      updatedAt: DateTime(2024, 6, 20),
    );
    fakeRepo.latestAreaToReturn = recent;

    final result = await useCase.execute('Min Buri');

    expect(result, isNotNull);
    expect(result!.id, 'recent-doc');
    expect(result.updatedAt, DateTime(2024, 6, 20));
  });

  // ── Test 3 ──────────────────────────────────────────────────────────────
  test('returns null when no area found for district', () async {
    fakeRepo.latestAreaToReturn = null;

    final result = await useCase.execute('Unknown District');

    expect(result, isNull);
  });

  // ── Test 4 ──────────────────────────────────────────────────────────────
  test(
    'filters by district name correctly — passes district to repository',
    () async {
      fakeRepo.latestAreaToReturn = _fakeArea(district: 'Khlong Toei');

      await useCase.execute('Khlong Toei');

      // The use case must forward the exact district name to the repository.
      expect(fakeRepo.capturedDistrict, 'Khlong Toei');
    },
  );
}
