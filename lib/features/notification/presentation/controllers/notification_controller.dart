import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/use_cases/get_notifications_use_case.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/use_cases/get_unread_count_use_case.dart';
import 'package:aedes_alert_yungrai/features/notification/domain/use_cases/mark_notification_read_use_case.dart';
import 'package:aedes_alert_yungrai/features/notification/presentation/controllers/notification_state.dart';

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markAsRead,
  }) : _getNotifications = getNotifications,
       _markAsRead = markAsRead,
       super(NotificationState.initial());

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markAsRead;

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

  /// Mark a single notification as read in Firestore and apply an optimistic
  /// local update so the UI reflects the change immediately.
  Future<void> markAsRead(String notifId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Optimistic update — reflect read state before the Firestore round-trip.
    final current = state.notifications.valueOrNull;
    if (current != null) {
      final updated = current.map((n) {
        if (n.id == notifId && !n.isReadBy(uid)) {
          return n.copyWithReadBy([...n.readBy, uid]);
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: AsyncValue.data(updated));
    }

    // Persist to Firestore (fire-and-forget; errors are silently ignored).
    await _markAsRead.execute(notifId, uid);
  }

  /// Mark every currently-loaded unread notification as read in bulk.
  Future<void> markAllAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final current = state.notifications.valueOrNull;
    if (current == null) return;

    final unread = current.where((n) => !n.isReadBy(uid)).toList();
    if (unread.isEmpty) return;

    // Optimistic local update first.
    final updated = current
        .map(
          (n) => n.isReadBy(uid) ? n : n.copyWithReadBy([...n.readBy, uid]),
        )
        .toList();
    state = state.copyWith(notifications: AsyncValue.data(updated));

    // Fire Firestore writes in parallel.
    await Future.wait(unread.map((n) => _markAsRead.execute(n.id, uid)));
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      return NotificationController(
        getNotifications: ref.watch(getNotificationsUseCaseProvider),
        markAsRead: ref.watch(markNotificationReadUseCaseProvider),
      );
    });

/// Real-time stream of the number of unread notifications for the current user.
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (uid.isEmpty) return Stream.value(0);
  return GetUnreadCountUseCase(
    NotificationRepositoryImpl(FirebaseFirestore.instance),
  ).execute(uid);
});
