import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Badge variant types
enum ProBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
  primary,
}

/// Badge size options
enum ProBadgeSize {
  small,
  medium,
  large,
}

/// FutsalPro Badge Component
/// Status badges and tags with consistent styling
class ProBadge extends StatelessWidget {
  final String text;
  final ProBadgeVariant variant;
  final ProBadgeSize size;
  final IconData? icon;
  final bool outlined;

  const ProBadge({
    super.key,
    required this.text,
    this.variant = ProBadgeVariant.neutral,
    this.size = ProBadgeSize.medium,
    this.icon,
    this.outlined = false,
  });

  Color get _backgroundColor {
    if (outlined) return Colors.transparent;
    switch (variant) {
      case ProBadgeVariant.success:
        return AppColors.successSurface;
      case ProBadgeVariant.warning:
        return AppColors.warningSurface;
      case ProBadgeVariant.error:
        return AppColors.errorSurface;
      case ProBadgeVariant.info:
        return AppColors.infoSurface;
      case ProBadgeVariant.primary:
        return AppColors.primary.withOpacity(0.15);
      case ProBadgeVariant.neutral:
        return AppColors.surfaceLightDark;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case ProBadgeVariant.success:
        return AppColors.success;
      case ProBadgeVariant.warning:
        return AppColors.warning;
      case ProBadgeVariant.error:
        return AppColors.error;
      case ProBadgeVariant.info:
        return AppColors.info;
      case ProBadgeVariant.primary:
        return AppColors.primary;
      case ProBadgeVariant.neutral:
        return AppColors.textSecondaryDark;
    }
  }

  Color get _borderColor {
    return _foregroundColor.withOpacity(0.3);
  }

  double get _fontSize {
    switch (size) {
      case ProBadgeSize.small:
        return 10;
      case ProBadgeSize.medium:
        return 12;
      case ProBadgeSize.large:
        return 14;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case ProBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case ProBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case ProBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppSpacing.borderRadiusSm,
        border: outlined ? Border.all(color: _borderColor, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _fontSize + 2,
              color: _foregroundColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: _foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status Dot indicator
class ProStatusDot extends StatelessWidget {
  final ProBadgeVariant variant;
  final double size;
  final bool animated;

  const ProStatusDot({
    super.key,
    this.variant = ProBadgeVariant.success,
    this.size = 8,
    this.animated = false,
  });

  Color get _color {
    switch (variant) {
      case ProBadgeVariant.success:
        return AppColors.success;
      case ProBadgeVariant.warning:
        return AppColors.warning;
      case ProBadgeVariant.error:
        return AppColors.error;
      case ProBadgeVariant.info:
        return AppColors.info;
      case ProBadgeVariant.primary:
        return AppColors.primary;
      case ProBadgeVariant.neutral:
        return AppColors.textTertiaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return _AnimatedStatusDot(color: _color, size: size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AnimatedStatusDot extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedStatusDot({
    required this.color,
    required this.size,
  });

  @override
  State<_AnimatedStatusDot> createState() => _AnimatedStatusDotState();
}

class _AnimatedStatusDotState extends State<_AnimatedStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 * _animation.value),
                blurRadius: 4 * _animation.value,
                spreadRadius: 1 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Booking status badge
class ProBookingStatusBadge extends StatelessWidget {
  final String status;

  const ProBookingStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    ProBadgeVariant variant;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        variant = ProBadgeVariant.warning;
        icon = Icons.schedule;
        label = 'Pending';
        break;
      case 'confirmed':
        variant = ProBadgeVariant.success;
        icon = Icons.check_circle_outline;
        label = 'Dikonfirmasi';
        break;
      case 'completed':
        variant = ProBadgeVariant.info;
        icon = Icons.done_all;
        label = 'Selesai';
        break;
      case 'cancelled':
        variant = ProBadgeVariant.error;
        icon = Icons.cancel_outlined;
        label = 'Dibatalkan';
        break;
      case 'active':
        variant = ProBadgeVariant.primary;
        icon = Icons.play_circle_outline;
        label = 'Berlangsung';
        break;
      default:
        variant = ProBadgeVariant.neutral;
        icon = Icons.info_outline;
        label = status;
    }

    return ProBadge(
      text: label,
      variant: variant,
      icon: icon,
    );
  }
}

/// Counter badge (for notifications, etc.)
class ProCounterBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final bool showZero;

  const ProCounterBadge({
    super.key,
    required this.count,
    this.color,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showZero) return const SizedBox.shrink();

    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 20),
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayCount,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
