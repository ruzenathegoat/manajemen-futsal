import 'package:flutter/material.dart';

/// FutsalPro Design System - Color Palette
/// Inspired by premium dark-mode dashboards with neon accent colors
class AppColors {
  AppColors._();

  // ============== PRIMARY BRAND COLORS ==============
  /// Primary accent - Neon green (inspired by reference design)
  static const Color primary = Color(0xFFB8F227);
  static const Color primaryLight = Color(0xFFD4FF4D);
  static const Color primaryDark = Color(0xFF8BC34A);
  
  /// Secondary accent - Cool cyan for highlights
  static const Color secondary = Color(0xFF00E5FF);
  static const Color secondaryLight = Color(0xFF6EFFFF);
  static const Color secondaryDark = Color(0xFF00B2CC);

  // ============== DARK THEME BACKGROUNDS ==============
  /// Main background - Deep dark
  static const Color backgroundDark = Color(0xFF0D0D0D);
  
  /// Surface colors for cards, dialogs
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceLightDark = Color(0xFF242424);
  static const Color surfaceElevatedDark = Color(0xFF2D2D2D);
  
  /// Card backgrounds with subtle elevation
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color cardHoverDark = Color(0xFF262626);

  // ============== LIGHT THEME BACKGROUNDS ==============
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ============== TEXT COLORS ==============
  /// Dark theme text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textTertiaryDark = Color(0xFF737373);
  static const Color textDisabledDark = Color(0xFF4D4D4D);
  
  /// Light theme text
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textTertiaryLight = Color(0xFF999999);
  static const Color textDisabledLight = Color(0xFFBBBBBB);

  // ============== SEMANTIC COLORS ==============
  /// Success states
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFF052E16);
  
  /// Warning states
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFF422006);
  
  /// Error states
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFF450A0A);
  
  /// Info states
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFF172554);

  // ============== CHART COLORS ==============
  static const List<Color> chartColors = [
    Color(0xFFB8F227), // Primary green
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF00E5FF), // Cyan
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Violet
  ];

  // ============== GRADIENT DEFINITIONS ==============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceDark, backgroundDark],
  );
  
  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF242424),
    ],
  );

  static LinearGradient accentGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary.withOpacity(0.15),
      primary.withOpacity(0.05),
    ],
  );

  // ============== BORDER COLORS ==============
  static const Color borderDark = Color(0xFF333333);
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderFocused = primary;

  // ============== OVERLAY COLORS ==============
  static Color overlayDark = Colors.black.withOpacity(0.6);
  static Color overlayLight = Colors.black.withOpacity(0.3);

  // ============== SHIMMER COLORS ==============
  static const Color shimmerBase = Color(0xFF2D2D2D);
  static const Color shimmerHighlight = Color(0xFF3D3D3D);

  // ============== STATUS COLORS FOR BOOKING ==============
  static const Color statusAvailable = Color(0xFF22C55E);
  static const Color statusBooked = Color(0xFF6B7280);
  static const Color statusSelected = primary;
  static const Color statusPending = Color(0xFFFBBF24);
  static const Color statusCompleted = Color(0xFF3B82F6);
  static const Color statusCancelled = Color(0xFFEF4444);
}
