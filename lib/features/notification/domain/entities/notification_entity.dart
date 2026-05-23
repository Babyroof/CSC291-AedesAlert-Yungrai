class NotificationEntity {
  const NotificationEntity({
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
}
