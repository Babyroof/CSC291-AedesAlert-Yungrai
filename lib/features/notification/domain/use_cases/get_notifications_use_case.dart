import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/entities/notification_entity.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/repositories/notification_repository.dart';
import 'package:aedes_alert_yungrai/features/notification/data/repositories/notification_repository_impl.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Future<List<NotificationEntity>> execute() => _repository.getNotifications();
}

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(
    ref.watch(notificationFeatureRepositoryProvider),
  );
});
