import 'package:aedes_alert_yungrai/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<NotificationEntity?> getLatestForArea(String areaId);
  Future<void> markAsRead(String notifId, String uid);
  Stream<int> unreadCountStream(String uid);
}
