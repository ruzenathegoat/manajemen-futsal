import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Time slot status
enum TimeSlotStatus {
  available,
  booked,
  selected,
  unavailable,
  partiallyBlocked,
}

/// Time slot data
class TimeSlotData {
  final int hour;
  final TimeSlotStatus status;
  final double? price;

  const TimeSlotData({
    required this.hour,
    required this.status,
    this.price,
  });
}

/// FutsalPro Time Slot Grid
/// Interactive time slot selection with animations
class ProTimeSlotGrid extends StatelessWidget {
  final List<TimeSlotData> slots;
  final int? selectedSlot;
  final int duration;
  final ValueChanged<int>? onSlotSelected;
  final int crossAxisCount;
  final double aspectRatio;

  const ProTimeSlotGrid({
    super.key,
    required this.slots,
    this.selectedSlot,
    this.duration = 1,
    this.onSlotSelected,
    this.crossAxisCount = 4,
    this.aspectRatio = 1.4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: AppSpacing.paddingMd,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedSlot == slot.hour;

        return _TimeSlotTile(
          slot: slot,
          isSelected: isSelected,
          duration: duration,
          onTap: slot.status == TimeSlotStatus.available ||
                  slot.status == TimeSlotStatus.selected
              ? () => onSlotSelected?.call(slot.hour)
              : null,
        );
      },
    );
  }
}

class _TimeSlotTile extends StatefulWidget {
  final TimeSlotData slot;
  final bool isSelected;
  final int duration;
  final VoidCallback? onTap;

  const _TimeSlotTile({
    required this.slot,
    required this.isSelected,
    required this.duration,
    this.onTap,
  });

  @override
  State<_TimeSlotTile> createState() => _TimeSlotTileState();
}

class _TimeSlotTileState extends State<_TimeSlotTile>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (widget.isSelected) {
      return AppColors.primary;
    }
    switch (widget.slot.status) {
      case TimeSlotStatus.available:
        return AppColors.surfaceDark;
      case TimeSlotStatus.booked:
        return AppColors.surfaceElevatedDark;
      case TimeSlotStatus.unavailable:
        return AppColors.surfaceElevatedDark;
      case TimeSlotStatus.partiallyBlocked:
        return AppColors.warningSurface;
      case TimeSlotStatus.selected:
        return AppColors.primary;
    }
  }

  Color get _borderColor {
    if (widget.isSelected) {
      return AppColors.primary;
    }
    switch (widget.slot.status) {
      case TimeSlotStatus.available:
        return AppColors.borderDark;
      case TimeSlotStatus.booked:
        return AppColors.textDisabledDark;
      case TimeSlotStatus.unavailable:
        return AppColors.textDisabledDark;
      case TimeSlotStatus.partiallyBlocked:
        return AppColors.warning;
      case TimeSlotStatus.selected:
        return AppColors.primary;
    }
  }

  Color get _textColor {
    if (widget.isSelected) {
      return Colors.black;
    }
    switch (widget.slot.status) {
      case TimeSlotStatus.available:
        return AppColors.textPrimaryDark;
      case TimeSlotStatus.booked:
        return AppColors.textDisabledDark;
      case TimeSlotStatus.unavailable:
        return AppColors.textDisabledDark;
      case TimeSlotStatus.partiallyBlocked:
        return AppColors.warning;
      case TimeSlotStatus.selected:
        return Colors.black;
    }
  }

  List<BoxShadow>? get _boxShadow {
    if (widget.isSelected) {
      return AppShadows.glowPrimary;
    }
    return null;
  }

  IconData? get _statusIcon {
    switch (widget.slot.status) {
      case TimeSlotStatus.booked:
        return Icons.block;
      case TimeSlotStatus.unavailable:
        return Icons.close;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: AppSpacing.durationNormal,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: _borderColor,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: _boxShadow,
          ),
          child: Stack(
            children: [
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.slot.hour}:00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    if (widget.isSelected && widget.duration > 1)
                      Text(
                        '- ${widget.slot.hour + widget.duration}:00',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _textColor.withOpacity(0.8),
                        ),
                      ),
                    if (_statusIcon != null)
                      Icon(
                        _statusIcon,
                        size: 12,
                        color: _textColor,
                      ),
                  ],
                ),
              ),

              // Selected indicator
              if (widget.isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: AppColors.primary,
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

/// Time slot legend
class ProTimeSlotLegend extends StatelessWidget {
  const ProTimeSlotLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: AppColors.surfaceDark,
          borderColor: AppColors.borderDark,
          label: 'Tersedia',
        ),
        _LegendItem(
          color: AppColors.surfaceElevatedDark,
          borderColor: AppColors.textDisabledDark,
          label: 'Terisi',
        ),
        _LegendItem(
          color: AppColors.warningSurface,
          borderColor: AppColors.warning,
          label: 'Tumpang tindih',
        ),
        _LegendItem(
          color: AppColors.primary,
          borderColor: AppColors.primary,
          label: 'Dipilih',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption(AppColors.textSecondaryDark),
        ),
      ],
    );
  }
}

/// Duration selector
class ProDurationSelector extends StatelessWidget {
  final List<int> durations;
  final int selectedDuration;
  final ValueChanged<int> onChanged;
  final String? unit;

  const ProDurationSelector({
    super.key,
    required this.durations,
    required this.selectedDuration,
    required this.onChanged,
    this.unit = 'Jam',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: durations.map((duration) {
          final isSelected = duration == selectedDuration;
          return GestureDetector(
            onTap: () => onChanged(duration),
            child: AnimatedContainer(
              duration: AppSpacing.durationFast,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                '$duration $unit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : AppColors.textSecondaryDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
