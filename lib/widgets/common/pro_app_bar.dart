import 'package:flutter/material.dart';
import '../../core/core.dart';
import 'pro_avatar.dart';

/// FutsalPro Custom App Bar
/// Modern app bar with gradient and glass effects
class ProAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final bool transparent;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;
  final double? elevation;

  const ProAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = false,
    this.transparent = false,
    this.backgroundColor,
    this.onBackPressed,
    this.elevation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: transparent
          ? Colors.transparent
          : backgroundColor ??
              (isDark ? AppColors.backgroundDark : AppColors.surfaceLight),
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: leading ??
          (showBackButton && canPop
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    size: 20,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTypography.titleLarge(
                    isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                )
              : null),
      actions: actions,
    );
  }
}

/// User dashboard app bar with greeting
class ProDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? userImage;
  final String greeting;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final int notificationCount;

  const ProDashboardAppBar({
    super.key,
    required this.userName,
    this.userImage,
    this.greeting = 'Selamat Datang',
    this.onProfileTap,
    this.onNotificationTap,
    this.onSearchTap,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // User info
            Expanded(
              child: Row(
                children: [
                  ProAvatar(
                    imageUrl: userImage,
                    name: userName,
                    size: ProAvatarSize.md,
                    onTap: onProfileTap,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTypography.bodySmall(
                            isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          userName,
                          style: AppTypography.titleMedium(
                            isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onSearchTap != null)
                  _ActionButton(
                    icon: Icons.search,
                    onTap: onSearchTap,
                    isDark: isDark,
                  ),
                if (onNotificationTap != null) ...[
                  const SizedBox(width: 4),
                  _NotificationButton(
                    count: notificationCount,
                    onTap: onNotificationTap,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark
                : AppColors.textPrimaryLight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final bool isDark;

  const _NotificationButton({
    required this.count,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _ActionButton(
          icon: Icons.notifications_outlined,
          onTap: onTap,
          isDark: isDark,
        ),
        if (count > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
