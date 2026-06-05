import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/dashboard_summary_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/risk_count_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/presentation/controllers/dashboard_state.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_dashboard_summary_use_case.dart';

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController(this._getSummary) : super(DashboardState.initial());

  final GetDashboardSummaryUseCase _getSummary;

  /// [userLocation] — optional; used for Fix 4a (nearby-district chart).
  /// [userDistrict] — optional; when provided the AVG risk score card and the
  ///   monthly trend chart are scoped to this district only.
  /// [selectedMonthKey] — optional "YYYY-MM" string; used for Fix 6
  ///   (top-5 districts filtered to the selected month).
  bool _loaded = false;

  /// Cached district name from the first successful load.
  /// Re-used by [refresh] so the district filter is preserved across refreshes.
  String? _userDistrict;

  /// Full load — fetches all data from Firestore and resets to loading state.
  /// Guards against being called more than once unless [force] is true.
  Future<void> loadDashboard({
    GeoPoint? userLocation,
    String? userDistrict,
    String? selectedMonthKey,
    bool force = false,
  }) async {
    if (_loaded && !force) return;
    _loaded = true;
    // Cache the district so refresh() can re-use it without re-reading
    // homeControllerProvider (which may no longer be available or up-to-date).
    if (userDistrict != null) _userDistrict = userDistrict;
    state = DashboardState.initial();
    try {
      final summary = await _getSummary.execute(
        userLocation: userLocation,
        userDistrict: userDistrict,
        selectedMonthKey: selectedMonthKey,
      );
      state = DashboardState(summary: AsyncValue.data(summary));
    } catch (e, st) {
      _loaded = false; // allow retry on error
      state = DashboardState(summary: AsyncValue.error(e, st));
    }
  }

  /// Switches the selected month without re-fetching the base trend data.
  /// Re-fetches both the top-5 areas list and the risk counts for [monthKey]
  /// so the stat cards reflect the new month filter (Fix 3).
  Future<void> selectMonth(String monthKey) async {
    final current = state.summary.valueOrNull;
    if (current == null) return;
    try {
      final results = await Future.wait([
        _getSummary.getTopAreas.execute(limit: 5, monthKey: monthKey),
        _getSummary.getRiskCounts.execute(selectedMonthKey: monthKey),
        _getSummary.getAverageScore.execute(
          userDistrict: _userDistrict,
          selectedMonthKey: monthKey,
        ),
      ]);
      state = DashboardState(
        summary: AsyncValue.data(
          DashboardSummaryModel(
            riskCounts: results[1] as RiskCountModel,
            averageRiskScore: results[2] as double?,
            monthlyTrend: current.monthlyTrend,
            topFiveAreas: results[0] as List<AreaModel>,
            selectedMonthKey: monthKey,
          ),
        ),
      );
    } catch (_) {
      // Keep existing state on error — month tap should not wipe the screen.
    }
  }

  Future<void> refresh({
    GeoPoint? userLocation,
    String? userDistrict,
    String? selectedMonthKey,
  }) => loadDashboard(
    userLocation: userLocation,
    // Fall back to the cached district when the caller does not supply one,
    // so pull-to-refresh keeps the same district filter as the first load.
    userDistrict: userDistrict ?? _userDistrict,
    selectedMonthKey: selectedMonthKey,
    force: true,
  );
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
      return DashboardController(ref.watch(getDashboardSummaryUseCaseProvider));
    });
