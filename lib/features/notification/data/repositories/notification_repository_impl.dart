import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/notification/data/models/notification_model.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/entities/notification_entity.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final snapshot = await _firestore
        .collection(AppConstants.notificationsCollection)
        .orderBy('sentAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NotificationDataModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<NotificationEntity?> getLatestForArea(String areaId) async {
    final areaRef = _firestore
        .collection(AppConstants.areasCollection)
        .doc(areaId);
    final snapshot = await _firestore
        .collection(AppConstants.notificationsCollection)
        .where('relatedZone', isEqualTo: areaRef)
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return NotificationDataModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Future<void> markAsRead(String notifId, String uid) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(notifId)
        .update({
          'readBy': FieldValue.arrayUnion([uid]),
        });
  }

  @override
  Stream<int> unreadCountStream(String uid) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationDataModel.fromFirestore(doc).toEntity())
              .where((notif) => !notif.isReadBy(uid))
              .length,
        );
  }
}

final notificationFeatureRepositoryProvider = Provider<NotificationRepository>((
  ref,
) {
  return NotificationRepositoryImpl(FirebaseFirestore.instance);
});
