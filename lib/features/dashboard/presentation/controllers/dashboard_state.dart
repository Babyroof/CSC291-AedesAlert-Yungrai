import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/dashboard_summary_model.dart';

class DashboardState {
  const DashboardState({required this.summary});

  final AsyncValue<DashboardSummaryModel?> summary;

  factory DashboardState.initial() =>
      const DashboardState(summary: AsyncValue.loading());

  DashboardState copyWith({AsyncValue<DashboardSummaryModel?>? summary}) {
    return DashboardState(summary: summary ?? this.summary);
  }
}
