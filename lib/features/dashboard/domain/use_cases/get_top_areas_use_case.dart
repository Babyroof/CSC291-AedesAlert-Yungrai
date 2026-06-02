import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/utils/date_formatter.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class GetTopAreasUseCase {
  const GetTopAreasUseCase(this._repository);

  final DashboardRepository _repository;

  /// Fix 6 — Groups area documents by [district], computes the average
  /// riskScore per district, filters to documents whose [updatedAt] falls
  /// in [monthKey] (format "YYYY-MM"), then returns the top [limit]
  /// districts sorted by average riskScore descending.
  ///
  /// The returned [AreaModel] objects have [district] as their [subDistrict]
  /// so that the existing UI row simply displays the district name.
  ///
  /// When [monthKey] is null all months are included (no time filter).
  Future<List<AreaModel>> execute({
    int limit = 5,
    String? monthKey,
  }) async {
    final areas = await _repository.getAllAreas();

    // Apply month filter when a key is provided.
    final filtered = monthKey == null
        ? areas
        : areas
            .where((a) => DateFormatter.toMonthKey(a.updatedAt) == monthKey)
            .toList();

    if (filtered.isEmpty) return [];

    // Group by district → accumulate scores.
    final Map<String, List<double>> scoresByDistrict = {};
    final Map<String, AreaModel> representativeByDistrict = {};

    for (final area in filtered) {
      scoresByDistrict.putIfAbsent(area.district, () => []).add(area.riskScore);
      // Keep the sub-district doc with highest score as the representative
      // (used to derive riskLevel for the badge colour).
      final prev = representativeByDistrict[area.district];
      if (prev == null || area.riskScore > prev.riskScore) {
        representativeByDistrict[area.district] = area;
      }
    }

    // Build one synthetic AreaModel per district using the average score.
    final districtModels = scoresByDistrict.entries.map((entry) {
      final district = entry.key;
      final scores = entry.value;
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      final rep = representativeByDistrict[district]!;

      // Derive riskLevel from the averaged score.
      final String level;
      if (avg >= 75) {
        level = 'critical';
      } else if (avg >= 50) {
        level = 'high';
      } else if (avg >= 25) {
        level = 'medium';
      } else {
        level = 'low';
      }

      // Use district name as the display name (subDistrict field).
      return AreaModel(
        id: rep.id,
        subDistrict: district,
        district: district,
        province: rep.province,
        location: rep.location,
        radius: rep.radius,
        riskScore: double.parse(avg.toStringAsFixed(1)),
        riskLevel: level,
        reportedAt: rep.reportedAt,
        updatedAt: rep.updatedAt,
      );
    }).toList()
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

    return districtModels.take(limit).toList();
  }
}

final getTopAreasUseCaseProvider = Provider<GetTopAreasUseCase>((ref) {
  return GetTopAreasUseCase(ref.watch(dashboardRepositoryProvider));
});
