import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/use_cases/get_notifications_use_case.dart';
import 'package:aedes_alert_yungrai/features/notification/presentation/controllers/notification_state.dart';

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController({required GetNotificationsUseCase getNotifications})
    : _getNotifications = getNotifications,
      super(NotificationState.initial());

  final GetNotificationsUseCase _getNotifications;

  Future<void> loadNotifications() async {
    state = NotificationState.initial();
    try {
      final notifications = await _getNotifications.execute();
      state = NotificationState(notifications: AsyncValue.data(notifications));
    } catch (e, st) {
      state = NotificationState(notifications: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() => loadNotifications();
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      return NotificationController(
        getNotifications: ref.watch(getNotificationsUseCaseProvider),
      );
    });
