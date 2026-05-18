import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/home/models/notification_model.dart';
import 'package:aedes_alert_yungrai/features/home/services/notification_repository.dart';
import 'package:aedes_alert_yungrai/features/home/services/notification_repository_impl.dart';

class GetLatestNotificationUseCase {
  GetLatestNotificationUseCase(this._repository, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final NotificationRepository _repository;
  final FirebaseFirestore _firestore;

  Future<NotificationModel?> execute(String areaId) {
    final areaRef = _firestore
        .collection(AppConstants.areasCollection)
        .doc(areaId);
    return _repository.getLatestForArea(areaRef);
  }
}

final getLatestNotificationUseCaseProvider =
    Provider<GetLatestNotificationUseCase>((ref) {
  return GetLatestNotificationUseCase(
    ref.watch(notificationRepositoryProvider),
  );
});
