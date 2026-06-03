import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/utils/date_formatter.dart';
import 'package:aedes_alert_yungrai/core/utils/geo_utils.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/monthly_risk_data_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/data/repositories/dashboard_repository_impl.dart';

/// Maximum number of recent months to surface in the month-filter tabs.
const int _kMaxMonths = 3;

/// Radius used to decide which districts are "nearby" when a user location
/// is supplied.  Falls back gracefully to all districts when null.
const double _kNearbyRadiusKm = 50.0;

class GetMonthlyTrendUseCase {
  const GetMonthlyTrendUseCase(this._repository);

  final DashboardRepository _repository;

  /// [userDistrict] — preferred filter. When a non-empty string is provided the
  /// chart only includes area documents whose [district] field matches exactly.
  /// Takes precedence over [userLocation] when both are supplied.
  ///
  /// [userLocation] — fallback filter. Used when [userDistrict] is null/empty.
  /// When provided the chart only includes area documents whose centre is within
  /// [_kNearbyRadiusKm] km of the user.
  /// When both are null every document is included (safe fallback).
  ///
  /// Fix 1 + 2: only real data months are returned, capped to the 3 most
  /// recent ones.
  /// Fix 4a: nearby-district filtering (now also supports district-name filter).
  Future<List<MonthlyRiskDataModel>> execute({
    String? userDistrict,
    GeoPoint? userLocation,
  }) async {
    final areas = await _repository.getAllAreas();

    // Prefer district-name filter; fall back to GeoPoint radius; else all areas.
    final List<AreaModel> filtered;
    if (userDistrict != null && userDistrict.isNotEmpty) {
      final byDistrict = areas
          .where((a) => a.district == userDistrict)
          .toList();
      // Fall back to all areas when district filter returns nothing.
      filtered = byDistrict.isNotEmpty ? byDistrict : areas;
    } else if (userLocation != null) {
      final byRadius = areas.where((a) {
        final distKm = GeoUtils.distanceInKm(userLocation, a.location);
        return distKm <= _kNearbyRadiusKm;
      }).toList();
      filtered = byRadius.isNotEmpty ? byRadius : areas;
    } else {
      filtered = areas;
    }

    // Bug 1 fix — build per-month, per-district buckets so that each district
    // contributes equally to the monthly average regardless of how many
    // sub-district documents it has.
    final Map<String, Map<String, List<double>>> monthDistrictBuckets = {};

    for (final area in filtered) {
      final monthKey = DateFormatter.toMonthKey(area.reportedAt);
      monthDistrictBuckets
          .putIfAbsent(monthKey, () => {})
          .putIfAbsent(area.district, () => [])
          .add(area.riskScore);
    }

    // Compute two-step average: avg per district, then avg of district avgs.
    final allMonths = <MonthlyRiskDataModel>[];
    for (final monthEntry in monthDistrictBuckets.entries) {
      final monthKey = monthEntry.key;
      final byDistrict = monthEntry.value;

      // Step 1: average riskScore per district.
      final districtAvgList = byDistrict.values
          .map((scores) => scores.reduce((a, b) => a + b) / scores.length)
          .toList();

      // Step 2: average of district averages.
      final monthAvg =
          districtAvgList.reduce((a, b) => a + b) / districtAvgList.length;

      // Total area-doc count (for reference).
      final totalCount = byDistrict.values.fold<int>(
        0,
        (acc, scores) => acc + scores.length,
      );

      allMonths.add(
        MonthlyRiskDataModel.fromComputedAvg(monthKey, monthAvg, totalCount),
      );
    }

    // Sort newest first, keep only the _kMaxMonths most recent real months,
    // then re-sort ascending for chronological display.
    allMonths.sort((a, b) => b.monthKey.compareTo(a.monthKey));
    final recent = allMonths.take(_kMaxMonths).toList()
      ..sort((a, b) => a.monthKey.compareTo(b.monthKey));

    return recent;
  }
}

final getMonthlyTrendUseCaseProvider = Provider<GetMonthlyTrendUseCase>((ref) {
  return GetMonthlyTrendUseCase(ref.watch(dashboardRepositoryProvider));
});
