import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<AreaModel>> getAllAreas() async {
    final snapshot = await _firestore
        .collection(AppConstants.areasCollection)
        .get();
    return snapshot.docs.map(AreaModel.fromFirestore).toList();
  }

  @override
  Future<List<AreaModel>> getTopAreasByRisk({int limit = 5}) async {
    final snapshot = await _firestore
        .collection(AppConstants.areasCollection)
        .orderBy('riskScore', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(AreaModel.fromFirestore).toList();
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(FirebaseFirestore.instance);
});
