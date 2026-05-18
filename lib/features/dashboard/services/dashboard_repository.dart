import 'package:aedes_alert_yungrai/features/home/models/area_model.dart';

abstract class DashboardRepository {
  Future<List<AreaModel>> getAllAreas();
  Future<List<AreaModel>> getTopAreasByRisk({int limit = 5});
}
