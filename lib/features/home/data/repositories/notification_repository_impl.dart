import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/notification_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<NotificationModel?> getLatestForArea(
    DocumentReference areaRef,
  ) async {
    final snapshot = await _firestore
        .collection(AppConstants.notificationsCollection)
        .where('relatedZone', isEqualTo: areaRef)
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return NotificationModel.fromFirestore(snapshot.docs.first);
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(FirebaseFirestore.instance);
});
