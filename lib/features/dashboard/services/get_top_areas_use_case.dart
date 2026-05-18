import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/dashboard_repository.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/dashboard_repository_impl.dart';

class GetTopAreasUseCase {
  const GetTopAreasUseCase(this._repository);

  final DashboardRepository _repository;

  Future<List<AreaModel>> execute({int limit = 5}) =>
      _repository.getTopAreasByRisk(limit: limit);
}

final getTopAreasUseCaseProvider = Provider<GetTopAreasUseCase>((ref) {
  return GetTopAreasUseCase(ref.watch(dashboardRepositoryProvider));
});
