import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/repositories/notification_repository.dart';
import 'package:aedes_alert_yungrai/features/notification/data/repositories/notification_repository_impl.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> execute(String notifId, String uid) =>
      _repository.markAsRead(notifId, uid);
}

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
      return MarkNotificationReadUseCase(
        ref.watch(notificationFeatureRepositoryProvider),
      );
    });