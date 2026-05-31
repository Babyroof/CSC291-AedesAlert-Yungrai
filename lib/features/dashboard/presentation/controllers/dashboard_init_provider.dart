import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/dashboard/presentation/controllers/dashboard_controller.dart';

final dashboardInitProvider = Provider<void>((ref) {
  ref.read(dashboardControllerProvider.notifier).loadDashboard();
});
