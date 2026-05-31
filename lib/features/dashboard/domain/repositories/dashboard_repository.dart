import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';

abstract class DashboardRepository {
  Future<List<AreaModel>> getAllAreas();
  Future<List<AreaModel>> getTopAreasByRisk({int limit = 5});
}
