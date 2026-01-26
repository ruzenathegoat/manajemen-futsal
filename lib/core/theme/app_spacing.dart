import 'package:flutter/material.dart';

/// FutsalPro Design System - Spacing & Dimensions
/// Consistent spacing scale based on 4px grid
class AppSpacing {
  AppSpacing._();

  // ============== BASE SPACING SCALE ==============
  /// 4px - Extra extra small
  static const double xxs = 4.0;
  
  /// 8px - Extra small
  static const double xs = 8.0;
  
  /// 12px - Small
  static const double sm = 12.0;
  
  /// 16px - Medium (base)
  static const double md = 16.0;
  
  /// 20px - Medium large
  static const double ml = 20.0;
  
  /// 24px - Large
  static const double lg = 24.0;
  
  /// 32px - Extra large
  static const double xl = 32.0;
  
  /// 40px - Extra extra large
  static const double xxl = 40.0;
  
  /// 48px - Huge
  static const double huge = 48.0;
  
  /// 64px - Massive
  static const double massive = 64.0;

  // ============== PADDING PRESETS ==============
  static const EdgeInsets paddingXxs = EdgeInsets.all(xxs);
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // ============== HORIZONTAL PADDING ==============
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // ============== VERTICAL PADDING ==============
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // ============== SCREEN PADDING ==============
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const double screenPaddingValue = md;

  // ============== BORDER RADIUS ==============
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusRound = 999.0;

  // ============== BORDER RADIUS PRESETS ==============
  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusRound = BorderRadius.circular(radiusRound);

  // ============== CARD DIMENSIONS ==============
  static const double cardMinHeight = 80.0;
  static const double cardMediumHeight = 120.0;
  static const double cardLargeHeight = 200.0;

  // ============== BUTTON DIMENSIONS ==============
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightXl = 56.0;
  
  static const double buttonMinWidth = 120.0;
  static const double buttonIconSize = 20.0;

  // ============== INPUT DIMENSIONS ==============
  static const double inputHeight = 52.0;
  static const double inputHeightSm = 44.0;
  static const double inputIconSize = 22.0;

  // ============== ICON SIZES ==============
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double iconXxl = 48.0;

  // ============== AVATAR SIZES ==============
  static const double avatarXs = 32.0;
  static const double avatarSm = 40.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 80.0;
  static const double avatarXxl = 120.0;

  // ============== DIVIDER & BORDER ==============
  static const double dividerThickness = 1.0;
  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;

  // ============== ELEVATION / SHADOW ==============
  static const double elevationNone = 0.0;
  static const double elevationXs = 2.0;
  static const double elevationSm = 4.0;
  static const double elevationMd = 8.0;
  static const double elevationLg = 16.0;
  static const double elevationXl = 24.0;

  // ============== ANIMATION DURATIONS ==============
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationVerySlow = Duration(milliseconds: 500);

  // ============== BREAKPOINTS (Responsive) ==============
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  static const double breakpointWide = 1536.0;

  // ============== SIDEBAR / DRAWER ==============
  static const double sidebarWidthCollapsed = 72.0;
  static const double sidebarWidthExpanded = 280.0;
  static const double drawerWidth = 300.0;

  // ============== APP BAR ==============
  static const double appBarHeight = 64.0;
  static const double appBarHeightSm = 56.0;

  // ============== BOTTOM NAV ==============
  static const double bottomNavHeight = 72.0;
}

/// Extension for responsive sizing
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isMobile => screenWidth < AppSpacing.breakpointMobile;
  bool get isTablet => screenWidth >= AppSpacing.breakpointMobile && screenWidth < AppSpacing.breakpointDesktop;
  bool get isDesktop => screenWidth >= AppSpacing.breakpointDesktop;
  bool get isWide => screenWidth >= AppSpacing.breakpointWide;
  
  /// Get responsive value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    if (isWide && wide != null) return wide;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
  
  /// Get responsive padding
  EdgeInsets get responsivePadding => responsive(
    mobile: AppSpacing.paddingMd,
    tablet: AppSpacing.paddingLg,
    desktop: AppSpacing.paddingXl,
  );
  
  /// Get responsive grid columns
  int get responsiveGridColumns => responsive(
    mobile: 1,
    tablet: 2,
    desktop: 3,
    wide: 4,
  );
}
