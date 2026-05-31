import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/entities/notification_entity.dart';

class NotificationDataModel {
  const NotificationDataModel({
    required this.id,
    required this.title,
    required this.body,
    this.relatedZoneId,
    required this.sentAt,
  });

  final String id;
  final String title;
  final String body;
  final String? relatedZoneId;
  final DateTime sentAt;

  factory NotificationDataModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final relatedZone = data['relatedZone'] as DocumentReference?;
    return NotificationDataModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      relatedZoneId: relatedZone?.id,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    title: title,
    body: body,
    relatedZoneId: relatedZoneId,
    sentAt: sentAt,
  );
}
