import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Navigation item data
class ProNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badge;

  const ProNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// FutsalPro Bottom Navigation Bar
/// Modern bottom navigation with glow effect on selected item
class ProBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<ProNavItem> items;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const ProBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavItem(
                item: items[index],
                isSelected: index == currentIndex,
                onTap: () => onTap(index),
                selectedColor: selectedColor ?? AppColors.primary,
                unselectedColor: unselectedColor ??
                    (isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final ProNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppSpacing.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: AppSpacing.durationNormal,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? widget.selectedColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isSelected
                          ? (widget.item.activeIcon ?? widget.item.icon)
                          : widget.item.icon,
                      size: 22,
                      color: widget.isSelected
                          ? widget.selectedColor
                          : widget.unselectedColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: AppSpacing.durationNormal,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isSelected
                          ? widget.selectedColor
                          : widget.unselectedColor,
                    ),
                    child: Text(widget.item.label),
                  ),
                ],
              ),
              if (widget.item.badge != null && widget.item.badge! > 0)
                Positioned(
                  right: 4,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      widget.item.badge! > 99
                          ? '99+'
                          : widget.item.badge.toString(),
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
          ),
        ),
      ),
    );
  }
}

/// Floating bottom navigation with center FAB
class ProFloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<ProNavItem> items;
  final ValueChanged<int> onTap;
  final VoidCallback? onFabPressed;
  final IconData? fabIcon;

  const ProFloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.onFabPressed,
    this.fabIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final halfLength = items.length ~/ 2;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding,
      ),
      child: SizedBox(
        height: AppSpacing.bottomNavHeight + 20,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: AppSpacing.bottomNavHeight,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Left items
                    ...List.generate(
                      halfLength,
                      (index) => _NavItem(
                        item: items[index],
                        isSelected: index == currentIndex,
                        onTap: () => onTap(index),
                        selectedColor: AppColors.primary,
                        unselectedColor: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                    // Space for FAB
                    const SizedBox(width: 60),
                    // Right items
                    ...List.generate(
                      items.length - halfLength,
                      (index) {
                        final actualIndex = halfLength + index;
                        return _NavItem(
                          item: items[actualIndex],
                          isSelected: actualIndex == currentIndex,
                          onTap: () => onTap(actualIndex),
                          selectedColor: AppColors.primary,
                          unselectedColor: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Center FAB
            if (onFabPressed != null)
              Positioned(
                bottom: AppSpacing.bottomNavHeight - 28,
                child: GestureDetector(
                  onTap: onFabPressed,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.glowPrimary,
                    ),
                    child: Icon(
                      fabIcon ?? Icons.add,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
