import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Button variant types
enum ProButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  danger,
}

/// Button size options
enum ProButtonSize {
  small,
  medium,
  large,
}

/// FutsalPro Custom Button Component
/// Animated button with multiple variants and glow effects
class ProButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ProButtonVariant variant;
  final ProButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final double? width;

  const ProButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ProButtonVariant.primary,
    this.size = ProButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.width,
  });

  @override
  State<ProButton> createState() => _ProButtonState();
}

class _ProButtonState extends State<ProButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppSpacing.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height {
    switch (widget.size) {
      case ProButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case ProButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case ProButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case ProButtonSize.small:
        return 12;
      case ProButtonSize.medium:
        return 14;
      case ProButtonSize.large:
        return 16;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case ProButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ProButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ProButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  Color get _backgroundColor {
    if (widget.onPressed == null) {
      return AppColors.surfaceElevatedDark;
    }
    switch (widget.variant) {
      case ProButtonVariant.primary:
        return AppColors.primary;
      case ProButtonVariant.secondary:
        return AppColors.surfaceLightDark;
      case ProButtonVariant.outlined:
      case ProButtonVariant.ghost:
        return Colors.transparent;
      case ProButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color get _foregroundColor {
    if (widget.onPressed == null) {
      return AppColors.textDisabledDark;
    }
    switch (widget.variant) {
      case ProButtonVariant.primary:
        return Colors.black;
      case ProButtonVariant.secondary:
        return AppColors.textPrimaryDark;
      case ProButtonVariant.outlined:
        return AppColors.primary;
      case ProButtonVariant.ghost:
        return AppColors.primary;
      case ProButtonVariant.danger:
        return Colors.white;
    }
  }

  Border? get _border {
    if (widget.variant == ProButtonVariant.outlined) {
      return Border.all(
        color: widget.onPressed == null
            ? AppColors.borderDark
            : AppColors.primary,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? get _boxShadow {
    if (widget.onPressed == null || !_isPressed) {
      return null;
    }
    switch (widget.variant) {
      case ProButtonVariant.primary:
        return AppShadows.glowPrimary;
      case ProButtonVariant.danger:
        return AppShadows.glowError;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.onPressed == null
            ? null
            : (_) {
                setState(() => _isPressed = true);
                _controller.forward();
              },
        onTapUp: widget.onPressed == null
            ? null
            : (_) {
                setState(() => _isPressed = false);
                _controller.reverse();
                widget.onPressed?.call();
              },
        onTapCancel: widget.onPressed == null
            ? null
            : () {
                setState(() => _isPressed = false);
                _controller.reverse();
              },
        child: AnimatedContainer(
          duration: AppSpacing.durationFast,
          width: widget.isExpanded ? double.infinity : widget.width,
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: AppSpacing.borderRadiusMd,
            border: _border,
            boxShadow: _boxShadow,
          ),
          child: Row(
            mainAxisSize:
                widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(_foregroundColor),
                  ),
                ),
              ] else ...[
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: _fontSize + 4,
                    color: _foregroundColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    color: _foregroundColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    widget.trailingIcon,
                    size: _fontSize + 4,
                    color: _foregroundColor,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon Button with glow effect
class ProIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const ProIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 44,
    this.tooltip,
  });

  @override
  State<ProIconButton> createState() => _ProIconButtonState();
}

class _ProIconButtonState extends State<ProIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: AppSpacing.durationFast,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (_isHovered
                    ? AppColors.surfaceLightDark
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(widget.size / 2),
          ),
          child: Icon(
            widget.icon,
            size: widget.size * 0.5,
            color: widget.color ??
                (widget.onPressed == null
                    ? AppColors.textDisabledDark
                    : AppColors.textPrimaryDark),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }
}
