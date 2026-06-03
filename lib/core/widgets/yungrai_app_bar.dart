import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../../features/notification/presentation/controllers/notification_controller.dart';

class YungraiAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const YungraiAppBar({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            )
          : null,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pest_control, color: AppColors.primary, size: 28),
          SizedBox(width: 8),
          Text(
            'Yungrai',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => context.push('/notification'),
            child: Badge(
              isLabelVisible: unreadCount > 0,
              smallSize: 8,
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
