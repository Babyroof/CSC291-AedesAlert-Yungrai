import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/utils/date_formatter.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/data/repositories/dashboard_repository_impl.dart';

// Pipeline trace for the AVG RISK SCORE card:
//
// QUERY:  DashboardRepositoryImpl.getAllAreas() — fetches ALL documents from
//         the `areas` Firestore collection (no server-side filters).
//
// FIELD:  area.updatedAt (DateTime) — converted to "YYYY-MM" month key via
//         DateFormatter.toMonthKey().  All seed documents have
//         updatedAt = Timestamp.now(), so they all land in the same month.
//
// FIX:    When [userDistrict] is provided, filter to only that district before
//         computing the monthly average.  This makes the AVG card show the user's
//         own district average rather than the city-wide mean.
//
//         If [userDistrict] is null/empty: fall back to averaging ALL districts
//         (existing behavior — keeps the card useful even without location).
//
//         Two-step formula (same as GetMonthlyTrendUseCase):
//           Step 1 — filter to selectedMonthKey (or most-recent month when null).
//           Step 2 — group by district, avg riskScore per district.
//           Step 3 — avg of district averages → final score.
//
// FORMULA:
//   monthAvg = sum(districtAvg_i) / districtCount
//   where districtAvg_i = sum(scores in district i) / count(scores in district i)

class GetAverageRiskScoreUseCase {
  const GetAverageRiskScoreUseCase(this._repository);

  final DashboardRepository _repository;

  /// [userDistrict] — optional district name string.
  /// When provided only areas matching that district are included in the avg.
  /// When null or empty returns null — no district known, so no avg to show.
  ///
  /// [selectedMonthKey] — optional "YYYY-MM" string.
  /// When null the most-recent month found in the data is used.
  Future<double?> execute({
    String? userDistrict,
    String? selectedMonthKey,
  }) async {
    // Without a district we cannot compute a meaningful district-scoped avg.
    if (userDistrict == null || userDistrict.isEmpty) return null;

    final areas = await _repository.getAllAreas();
    if (areas.isEmpty) return null;

    // Filter to user's district.
    final districtFiltered = areas
        .where((a) => a.district == userDistrict)
        .toList();

    // If the district filter returns nothing (stale/invalid name) return null
    // rather than silently falling back to a city-wide average.
    if (districtFiltered.isEmpty) return null;

    final source = districtFiltered;

    // Determine effective month key.
    String? effectiveKey = selectedMonthKey;
    if (effectiveKey == null) {
      final keys = source.map((a) => DateFormatter.toMonthKey(a.reportedAt));
      effectiveKey = keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    }

    // Filter to the selected month.
    final filtered = source
        .where((a) => DateFormatter.toMonthKey(a.reportedAt) == effectiveKey)
        .toList();
    if (filtered.isEmpty) return null;

    // Step 1: group by district, compute per-district average.
    final Map<String, List<double>> byDistrict = {};
    for (final area in filtered) {
      byDistrict.putIfAbsent(area.district, () => []).add(area.riskScore);
    }

    // Step 2: average of district averages.
    final districtAvgs = byDistrict.values.map(
      (scores) => scores.reduce((a, b) => a + b) / scores.length,
    );
    final monthAvg = districtAvgs.reduce((a, b) => a + b) / districtAvgs.length;
    return double.parse(monthAvg.toStringAsFixed(1));
  }
}

final getAverageRiskScoreUseCaseProvider = Provider<GetAverageRiskScoreUseCase>(
  (ref) {
    return GetAverageRiskScoreUseCase(ref.watch(dashboardRepositoryProvider));
  },
);
