import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';

class YungraiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const YungraiAppBar({
    super.key,
    this.hasNotification = true,
    this.showBackButton = false,
  });

  final bool hasNotification;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pest_control, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          const Text(
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
              isLabelVisible: hasNotification,
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
