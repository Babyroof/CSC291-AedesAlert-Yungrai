import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/entities/notification_entity.dart';

class NotificationState {
  const NotificationState({required this.notifications});

  final AsyncValue<List<NotificationEntity>> notifications;

  factory NotificationState.initial() =>
      const NotificationState(notifications: AsyncValue.loading());

  NotificationState copyWith({
    AsyncValue<List<NotificationEntity>>? notifications,
  }) =>
      NotificationState(notifications: notifications ?? this.notifications);
}
