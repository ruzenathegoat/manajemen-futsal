import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/core.dart';

/// Avatar size options
enum ProAvatarSize {
  xs,
  sm,
  md,
  lg,
  xl,
  xxl,
}

/// FutsalPro Avatar Component
/// User avatar with multiple variants and status indicator
class ProAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final ProAvatarSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBorder;
  final Color? borderColor;
  final Widget? statusIndicator;
  final VoidCallback? onTap;

  const ProAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = ProAvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.showBorder = false,
    this.borderColor,
    this.statusIndicator,
    this.onTap,
  });

  double get _size {
    switch (size) {
      case ProAvatarSize.xs:
        return AppSpacing.avatarXs;
      case ProAvatarSize.sm:
        return AppSpacing.avatarSm;
      case ProAvatarSize.md:
        return AppSpacing.avatarMd;
      case ProAvatarSize.lg:
        return AppSpacing.avatarLg;
      case ProAvatarSize.xl:
        return AppSpacing.avatarXl;
      case ProAvatarSize.xxl:
        return AppSpacing.avatarXxl;
    }
  }

  double get _fontSize {
    switch (size) {
      case ProAvatarSize.xs:
        return 12;
      case ProAvatarSize.sm:
        return 14;
      case ProAvatarSize.md:
        return 18;
      case ProAvatarSize.lg:
        return 24;
      case ProAvatarSize.xl:
        return 32;
      case ProAvatarSize.xxl:
        return 40;
    }
  }

  double get _statusSize {
    switch (size) {
      case ProAvatarSize.xs:
        return 8;
      case ProAvatarSize.sm:
        return 10;
      case ProAvatarSize.md:
        return 12;
      case ProAvatarSize.lg:
        return 14;
      case ProAvatarSize.xl:
        return 16;
      case ProAvatarSize.xxl:
        return 20;
    }
  }

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark ? AppColors.surfaceLightDark : AppColors.primary.withOpacity(0.1));
    final fgColor = foregroundColor ??
        (isDark ? AppColors.primary : AppColors.primaryDark);

    Widget avatar = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.primary,
                width: 2,
              )
            : null,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(fgColor),
                errorWidget: (context, url, error) =>
                    _buildPlaceholder(fgColor),
              ),
            )
          : _buildPlaceholder(fgColor),
    );

    if (statusIndicator != null) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: _statusSize,
              height: _statusSize,
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: statusIndicator,
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildPlaceholder(Color color) {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Avatar with online/offline status
class ProUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final ProAvatarSize size;
  final bool isOnline;
  final VoidCallback? onTap;

  const ProUserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = ProAvatarSize.md,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProAvatar(
      imageUrl: imageUrl,
      name: name,
      size: size,
      onTap: onTap,
      statusIndicator: isOnline
          ? Container(
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// Avatar group for multiple users
class ProAvatarGroup extends StatelessWidget {
  final List<String?> imageUrls;
  final List<String?> names;
  final ProAvatarSize size;
  final int maxDisplay;
  final double overlap;

  const ProAvatarGroup({
    super.key,
    required this.imageUrls,
    required this.names,
    this.size = ProAvatarSize.sm,
    this.maxDisplay = 3,
    this.overlap = 0.3,
  });

  double get _avatarSize {
    switch (size) {
      case ProAvatarSize.xs:
        return AppSpacing.avatarXs;
      case ProAvatarSize.sm:
        return AppSpacing.avatarSm;
      case ProAvatarSize.md:
        return AppSpacing.avatarMd;
      case ProAvatarSize.lg:
        return AppSpacing.avatarLg;
      case ProAvatarSize.xl:
        return AppSpacing.avatarXl;
      case ProAvatarSize.xxl:
        return AppSpacing.avatarXxl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = imageUrls.length.clamp(0, maxDisplay);
    final remainingCount = imageUrls.length - displayCount;
    final overlapOffset = _avatarSize * overlap;

    return SizedBox(
      height: _avatarSize,
      width: _avatarSize +
          (displayCount - 1) * (_avatarSize - overlapOffset) +
          (remainingCount > 0 ? (_avatarSize - overlapOffset) : 0),
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * (_avatarSize - overlapOffset),
              child: ProAvatar(
                imageUrl: imageUrls[i],
                name: names[i],
                size: size,
                showBorder: true,
                borderColor: AppColors.backgroundDark,
              ),
            ),
          if (remainingCount > 0)
            Positioned(
              left: displayCount * (_avatarSize - overlapOffset),
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.backgroundDark,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: _avatarSize * 0.3,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
