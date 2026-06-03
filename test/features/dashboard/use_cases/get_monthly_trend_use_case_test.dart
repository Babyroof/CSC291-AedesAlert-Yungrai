import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_monthly_trend_use_case.dart';

// ---------------------------------------------------------------------------
// Manual fake repository — no build_runner / @GenerateMocks needed.
// ---------------------------------------------------------------------------

class FakeDashboardRepository implements DashboardRepository {
  List<AreaModel> areasToReturn = [];

  @override
  Future<List<AreaModel>> getAllAreas() async => areasToReturn;

  @override
  Future<List<AreaModel>> getTopAreasByRisk({int limit = 5}) async =>
      areasToReturn.take(limit).toList();
}

// ---------------------------------------------------------------------------
// Helper factory
// ---------------------------------------------------------------------------

AreaModel _makeArea({
  required String district,
  required double score,
  required DateTime updatedAt,
  String id = 'a',
}) =>
    AreaModel(
      id: id,
      subDistrict: 'Sub',
      district: district,
      province: 'Prov',
      location: const GeoPoint(13.7563, 100.5018),
      radius: 500,
      riskScore: score,
      riskLevel: 'medium',
      reportedAt: DateTime(2024, 1, 1),
      updatedAt: updatedAt,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeDashboardRepository fakeRepo;
  late GetMonthlyTrendUseCase useCase;

  setUp(() {
    fakeRepo = FakeDashboardRepository();
    useCase = GetMonthlyTrendUseCase(fakeRepo);
  });

  // ── Test 1 ──────────────────────────────────────────────────────────────
  test('returns exactly 3 months when Firestore has 3+ months of data',
      () async {
    // Seed areas across 5 different months (should be capped to 3 most recent)
    fakeRepo.areasToReturn = [
      _makeArea(district: 'D1', score: 50, updatedAt: DateTime(2024, 1, 1)),
      _makeArea(district: 'D1', score: 55, updatedAt: DateTime(2024, 2, 1)),
      _makeArea(district: 'D1', score: 60, updatedAt: DateTime(2024, 3, 1)),
      _makeArea(district: 'D1', score: 65, updatedAt: DateTime(2024, 4, 1)),
      _makeArea(district: 'D1', score: 70, updatedAt: DateTime(2024, 5, 1)),
    ];

    final result = await useCase.execute();

    // Should return exactly 3 (the _kMaxMonths cap).
    expect(result.length, 3);
    // Should be the 3 most recent months, in ascending order.
    expect(result[0].monthKey, '2024-03');
    expect(result[1].monthKey, '2024-04');
    expect(result[2].monthKey, '2024-05');
  });

  // ── Test 2 ──────────────────────────────────────────────────────────────
  test(
      'computes per-district avg correctly (two-step formula): '
      'district A [80,60] + district B [40] → month avg = 55.0', () async {
    // Both areas are in the same month (2024-06).
    fakeRepo.areasToReturn = [
      _makeArea(
          id: 'a1', district: 'A', score: 80, updatedAt: DateTime(2024, 6, 1)),
      _makeArea(
          id: 'a2', district: 'A', score: 60, updatedAt: DateTime(2024, 6, 2)),
      _makeArea(
          id: 'b1', district: 'B', score: 40, updatedAt: DateTime(2024, 6, 3)),
    ];

    final result = await useCase.execute();

    expect(result.length, 1);
    final bucket = result.first;
    expect(bucket.monthKey, '2024-06');
    // Step 1: avg(A) = (80+60)/2 = 70, avg(B) = 40.
    // Step 2: (70 + 40) / 2 = 55.0
    expect(bucket.avgRiskScore, closeTo(55.0, 0.01));
  });

  // ── Test 3 ──────────────────────────────────────────────────────────────
  test('returns empty list when no areas exist', () async {
    fakeRepo.areasToReturn = [];

    final result = await useCase.execute();

    expect(result, isEmpty);
  });

  // ── Test 4 ──────────────────────────────────────────────────────────────
  test('excludes future months — only includes months with real data',
      () async {
    // Only seed past months; no area should be synthesised for future dates.
    final now = DateTime.now();
    final pastMonth1 = DateTime(now.year - 1, 1, 1);
    final pastMonth2 = DateTime(now.year - 1, 2, 1);

    fakeRepo.areasToReturn = [
      _makeArea(district: 'D', score: 40, updatedAt: pastMonth1),
      _makeArea(district: 'D', score: 50, updatedAt: pastMonth2),
    ];

    final result = await useCase.execute();

    // All returned months must have real data (scores > 0 from the seed).
    expect(result, isNotEmpty);
    for (final m in result) {
      expect(m.areaCount, greaterThan(0));
    }

    // Verify no result has a monthKey later than the current month.
    final currentKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    for (final m in result) {
      expect(m.monthKey.compareTo(currentKey), lessThanOrEqualTo(0),
          reason: 'monthKey ${m.monthKey} is in the future');
    }
  });
}