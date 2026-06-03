import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/repositories/notification_repository.dart';
import 'package:aedes_alert_yungrai/features/notification/data/repositories/notification_repository_impl.dart';

class GetUnreadCountUseCase {
  const GetUnreadCountUseCase(this._repository);

  final NotificationRepository _repository;

  Stream<int> execute(String uid) => _repository.unreadCountStream(uid);
}

final getUnreadCountUseCaseProvider = Provider<GetUnreadCountUseCase>((ref) {
  return GetUnreadCountUseCase(
    ref.watch(notificationFeatureRepositoryProvider),
  );
});
