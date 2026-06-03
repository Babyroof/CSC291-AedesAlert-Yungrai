class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.relatedZoneId,
    required this.sentAt,
    this.readBy = const [],
  });

  final String id;
  final String title;
  final String body;
  final String? relatedZoneId;
  final DateTime sentAt;
  final List<String> readBy;

  bool isReadBy(String uid) => readBy.contains(uid);

  NotificationEntity copyWithReadBy(List<String> readBy) => NotificationEntity(
    id: id,
    title: title,
    body: body,
    relatedZoneId: relatedZoneId,
    sentAt: sentAt,
    readBy: readBy,
  );
}
