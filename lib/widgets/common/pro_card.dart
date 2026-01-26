import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Card variant types
enum ProCardVariant {
  standard,
  outlined,
  elevated,
  gradient,
  glow,
}

/// FutsalPro Custom Card Component
/// Animated card with multiple variants and hover effects
class ProCard extends StatefulWidget {
  final Widget child;
  final ProCardVariant variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const ProCard({
    super.key,
    required this.child,
    this.variant = ProCardVariant.standard,
    this.padding,
    this.margin,
    this.color,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  @override
  State<ProCard> createState() => _ProCardState();
}

class _ProCardState extends State<ProCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppSpacing.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.color != null) return widget.color!;

    switch (widget.variant) {
      case ProCardVariant.standard:
      case ProCardVariant.outlined:
        return isDark ? AppColors.cardDark : AppColors.cardLight;
      case ProCardVariant.elevated:
        return isDark ? AppColors.surfaceLightDark : AppColors.cardLight;
      case ProCardVariant.gradient:
      case ProCardVariant.glow:
        return isDark ? AppColors.cardDark : AppColors.cardLight;
    }
  }

  Border? get _border {
    if (widget.border != null) return widget.border;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (widget.variant) {
      case ProCardVariant.outlined:
        return Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        );
      case ProCardVariant.glow:
        return Border.all(
          color: AppColors.primary.withOpacity(_isHovered ? 0.5 : 0.3),
          width: 1,
        );
      default:
        if (isDark) {
          return Border.all(
            color: AppColors.borderDark,
            width: 1,
          );
        }
        return null;
    }
  }

  List<BoxShadow> get _boxShadow {
    if (widget.boxShadow != null) return widget.boxShadow!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (widget.variant) {
      case ProCardVariant.elevated:
        return isDark ? AppShadows.cardDark : AppShadows.cardLight;
      case ProCardVariant.glow:
        return _isHovered ? AppShadows.glowPrimaryIntense : AppShadows.glowPrimary;
      default:
        if (_isHovered && widget.onTap != null) {
          return AppShadows.cardHover;
        }
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: widget.onTap != null
              ? (_) {
                  setState(() => _isPressed = true);
                  _controller.forward();
                }
              : null,
          onTapUp: widget.onTap != null
              ? (_) {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                  widget.onTap?.call();
                }
              : null,
          onTapCancel: widget.onTap != null
              ? () {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                }
              : null,
          onLongPress: widget.onLongPress,
          child: AnimatedContainer(
            duration: AppSpacing.durationNormal,
            curve: Curves.easeOut,
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: widget.gradient != null ? null : _backgroundColor,
              gradient: widget.gradient,
              borderRadius: widget.borderRadius ?? AppSpacing.borderRadiusLg,
              border: _border,
              boxShadow: _boxShadow,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    return card;
  }
}

/// Stat Card for dashboard metrics
class ProStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? change;
  final bool? isPositive;
  final VoidCallback? onTap;

  const ProStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.change,
    this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;

    return ProCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ?? false)
                        ? AppColors.successSurface
                        : AppColors.errorSurface,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (isPositive ?? false)
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 10,
                        color: (isPositive ?? false)
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        change!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: (isPositive ?? false)
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.caption(
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Feature Card with icon and description
class ProFeatureCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ProFeatureCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;

    return ProCard(
      onTap: onTap,
      padding: AppSpacing.paddingLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: AppSpacing.borderRadiusLg,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall(
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(
                isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
