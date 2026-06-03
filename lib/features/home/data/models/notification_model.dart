import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
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

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final relatedZone = data['relatedZone'] as DocumentReference?;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String,
      body: data['body'] as String,
      relatedZoneId: relatedZone?.id,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
