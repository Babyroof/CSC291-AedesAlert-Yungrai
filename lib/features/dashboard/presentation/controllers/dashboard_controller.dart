import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/dashboard/presentation/controllers/dashboard_state.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_dashboard_summary_use_case.dart';

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController(this._getSummary) : super(DashboardState.initial());

  final GetDashboardSummaryUseCase _getSummary;

  /// [userLocation] — optional; used for Fix 4a (nearby-district chart).
  /// [selectedMonthKey] — optional "YYYY-MM" string; used for Fix 6
  ///   (top-5 districts filtered to the selected month).
  bool _loaded = false;

  /// Full load — fetches all data from Firestore and resets to loading state.
  /// Guards against being called more than once unless [force] is true.
  Future<void> loadDashboard({
    GeoPoint? userLocation,
    String? selectedMonthKey,
    bool force = false,
  }) async {
    if (_loaded && !force) return;
    _loaded = true;
    state = DashboardState.initial();
    try {
      final summary = await _getSummary.execute(
        userLocation: userLocation,
        selectedMonthKey: selectedMonthKey,
      );
      state = DashboardState(summary: AsyncValue.data(summary));
    } catch (e, st) {
      _loaded = false; // allow retry on error
      state = DashboardState(summary: AsyncValue.error(e, st));
    }
  }

  /// Switches the selected month tab without re-fetching the base data.
  /// Only re-fetches the top-5 areas list for the given [monthKey].
  Future<void> selectMonth(String monthKey) async {
    final current = state.summary.valueOrNull;
    if (current == null) return;
    try {
      final topAreas = await _getSummary.getTopAreas.execute(
        limit: 5,
        monthKey: monthKey,
      );
      state = DashboardState(
        summary: AsyncValue.data(
          current.copyWith(
            topFiveAreas: topAreas,
            selectedMonthKey: monthKey,
          ),
        ),
      );
    } catch (_) {
      // Keep existing state on error — tab tap should not wipe the screen.
    }
  }

  Future<void> refresh({
    GeoPoint? userLocation,
    String? selectedMonthKey,
  }) => loadDashboard(
    userLocation: userLocation,
    selectedMonthKey: selectedMonthKey,
    force: true,
  );
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
      return DashboardController(ref.watch(getDashboardSummaryUseCaseProvider));
    });
