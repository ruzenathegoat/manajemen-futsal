import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import '../../models/field_model.dart';
import '../common/pro_badge.dart';

/// FutsalPro Field Card
/// Beautiful field card with image, info, and actions
class ProFieldCard extends StatefulWidget {
  final FieldModel field;
  final VoidCallback? onTap;
  final VoidCallback? onBookPressed;
  final VoidCallback? onSchedulePressed;
  final bool showActions;
  final bool isCompact;

  const ProFieldCard({
    super.key,
    required this.field,
    this.onTap,
    this.onBookPressed,
    this.onSchedulePressed,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  State<ProFieldCard> createState() => _ProFieldCardState();
}

class _ProFieldCardState extends State<ProFieldCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

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

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (widget.isCompact) {
      return _buildCompactCard(currencyFormat);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
        onTapUp: widget.onTap != null
            ? (_) {
                _controller.reverse();
                widget.onTap?.call();
              }
            : null,
        onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: AppSpacing.durationNormal,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.borderDark,
              ),
              boxShadow: _isHovered ? AppShadows.cardHover : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                _buildImageSection(),

                // Content section
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.field.name,
                                  style: AppTypography.titleMedium(
                                    AppColors.textPrimaryDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sports_soccer,
                                      size: 14,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.field.type,
                                      style: AppTypography.caption(
                                        AppColors.textSecondaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currencyFormat.format(widget.field.basePrice),
                                style: AppTypography.priceSmall(AppColors.primary),
                              ),
                              Text(
                                '/jam',
                                style: AppTypography.caption(
                                  AppColors.textTertiaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        widget.field.description,
                        style: AppTypography.bodySmall(
                          AppColors.textSecondaryDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (widget.showActions) ...[
                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.calendar_today_outlined,
                                label: 'Jadwal',
                                onTap: widget.onSchedulePressed,
                                outlined: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _ActionButton(
                                icon: Icons.flash_on,
                                label: 'BOOKING',
                                onTap: widget.onBookPressed,
                                outlined: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(NumberFormat currencyFormat) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusSm,
              child: CachedNetworkImage(
                imageUrl: widget.field.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildImagePlaceholder(80),
                errorWidget: (_, __, ___) => _buildImagePlaceholder(80),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.field.name,
                    style: AppTypography.titleSmall(AppColors.textPrimaryDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.field.type,
                    style: AppTypography.caption(AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(widget.field.basePrice) + '/jam',
                    style: AppTypography.priceSmall(AppColors.primary),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiaryDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: widget.field.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildImagePlaceholder(null),
            errorWidget: (_, __, ___) => _buildImagePlaceholder(null),
          ),
        ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),

        // Status badge
        Positioned(
          top: 12,
          left: 12,
          child: ProBadge(
            text: widget.field.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
            variant: widget.field.isAvailable
                ? ProBadgeVariant.success
                : ProBadgeVariant.error,
            size: ProBadgeSize.small,
          ),
        ),

        // Popular badge (optional)
        if (widget.field.isPopular)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Populer',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(double? size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surfaceLightDark,
      child: Icon(
        Icons.stadium,
        size: size != null ? size * 0.4 : 48,
        color: AppColors.textTertiaryDark,
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outlined;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.outlined,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: AppSpacing.durationFast,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: widget.outlined
              ? Colors.transparent
              : (_isPressed ? AppColors.primaryDark : AppColors.primary),
          borderRadius: AppSpacing.borderRadiusMd,
          border: widget.outlined
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: !widget.outlined && _isPressed ? AppShadows.glowPrimary : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: widget.outlined ? AppColors.primary : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.outlined ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
