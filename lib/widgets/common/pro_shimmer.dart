import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/core.dart';

/// FutsalPro Shimmer Loading Components
/// Skeleton loading states for better UX

class ProShimmer extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ProShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );
  }
}

/// Shimmer box placeholder
class ProShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const ProShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
        ),
      ),
    );
  }
}

/// Shimmer circle placeholder
class ProShimmerCircle extends StatelessWidget {
  final double size;

  const ProShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Card shimmer placeholder
class ProShimmerCard extends StatelessWidget {
  final double? height;
  final bool showImage;
  final int lines;

  const ProShimmerCard({
    super.key,
    this.height,
    this.showImage = true,
    this.lines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage) ...[
            ProShimmerBox(
              height: 120,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            const SizedBox(height: 12),
          ],
          ...List.generate(
            lines,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < lines - 1 ? 8 : 0),
              child: ProShimmerBox(
                width: index == lines - 1 ? 100 : double.infinity,
                height: index == 0 ? 20 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List item shimmer placeholder
class ProShimmerListItem extends StatelessWidget {
  final bool showAvatar;
  final bool showTrailing;

  const ProShimmerListItem({
    super.key,
    this.showAvatar = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingVerticalSm,
      child: Row(
        children: [
          if (showAvatar) ...[
            const ProShimmerCircle(size: 48),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProShimmerBox(
                  width: 150,
                  height: 16,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                const SizedBox(height: 8),
                ProShimmerBox(
                  width: 100,
                  height: 12,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 12),
            ProShimmerBox(
              width: 60,
              height: 32,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ],
        ],
      ),
    );
  }
}

/// Stat card shimmer placeholder
class ProShimmerStatCard extends StatelessWidget {
  const ProShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProShimmerBox(
                width: 40,
                height: 40,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              ProShimmerBox(
                width: 50,
                height: 20,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProShimmerBox(
            width: 100,
            height: 28,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          const SizedBox(height: 8),
          ProShimmerBox(
            width: 80,
            height: 14,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
        ],
      ),
    );
  }
}
