import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/dashboard/presentation/controllers/dashboard_state.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/use_cases/get_dashboard_summary_use_case.dart';

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController(this._getSummary) : super(DashboardState.initial());

  final GetDashboardSummaryUseCase _getSummary;

  Future<void> loadDashboard() async {
    state = DashboardState.initial();
    try {
      final summary = await _getSummary.execute();
      state = DashboardState(summary: AsyncValue.data(summary));
    } catch (e, st) {
      state = DashboardState(summary: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() => loadDashboard();
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController(ref.watch(getDashboardSummaryUseCaseProvider));
});
