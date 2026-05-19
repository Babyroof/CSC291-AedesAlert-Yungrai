import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<NotificationModel?> getLatestForArea(DocumentReference areaRef);
}
