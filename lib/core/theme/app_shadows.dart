import 'package:flutter/material.dart';
import 'app_colors.dart';

/// FutsalPro Design System - Shadows & Decorations
/// Premium shadow effects for depth and elevation
class AppShadows {
  AppShadows._();

  // ============== BASIC SHADOWS ==============
  static List<BoxShadow> none = [];

  static List<BoxShadow> xs = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // ============== GLOW SHADOWS (for dark theme) ==============
  static List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowPrimaryIntense = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowSecondary = [
    BoxShadow(
      color: AppColors.secondary.withOpacity(0.3),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowSuccess = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.3),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowError = [
    BoxShadow(
      color: AppColors.error.withOpacity(0.3),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  // ============== CARD SHADOWS ==============
  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardHover = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ============== INNER SHADOWS (for pressed states) ==============
  static List<BoxShadow> innerShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // ============== MODAL/DIALOG SHADOWS ==============
  static List<BoxShadow> modal = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 40,
      spreadRadius: 8,
      offset: const Offset(0, 16),
    ),
  ];

  // ============== BOTTOM SHEET SHADOWS ==============
  static List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 24,
      offset: const Offset(0, -8),
    ),
  ];

  // ============== FLOATING ACTION BUTTON ==============
  static List<BoxShadow> fab = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

/// Pre-built box decorations for common use cases
class AppDecorations {
  AppDecorations._();

  // ============== CARD DECORATIONS ==============
  static BoxDecoration cardDark = BoxDecoration(
    color: AppColors.cardDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.borderDark,
      width: 1,
    ),
  );

  static BoxDecoration cardLight = BoxDecoration(
    color: AppColors.cardLight,
    borderRadius: BorderRadius.circular(16),
    boxShadow: AppShadows.cardLight,
  );

  static BoxDecoration cardGlow = BoxDecoration(
    color: AppColors.cardDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.primary.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: AppShadows.glowPrimary,
  );

  // ============== INPUT DECORATIONS ==============
  static BoxDecoration inputDark = BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.borderDark,
      width: 1,
    ),
  );

  static BoxDecoration inputFocused = BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.primary,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  // ============== BUTTON DECORATIONS ==============
  static BoxDecoration buttonPrimary = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppShadows.glowPrimary,
  );

  static BoxDecoration buttonOutlined = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.primary,
      width: 2,
    ),
  );

  // ============== GRADIENT OVERLAYS ==============
  static BoxDecoration gradientOverlayTop = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.6),
        Colors.transparent,
      ],
    ),
  );

  static BoxDecoration gradientOverlayBottom = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.8),
      ],
    ),
  );

  // ============== CHIP/TAG DECORATIONS ==============
  static BoxDecoration chipSuccess = BoxDecoration(
    color: AppColors.successSurface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppColors.success.withOpacity(0.3),
      width: 1,
    ),
  );

  static BoxDecoration chipWarning = BoxDecoration(
    color: AppColors.warningSurface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppColors.warning.withOpacity(0.3),
      width: 1,
    ),
  );

  static BoxDecoration chipError = BoxDecoration(
    color: AppColors.errorSurface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppColors.error.withOpacity(0.3),
      width: 1,
    ),
  );

  static BoxDecoration chipInfo = BoxDecoration(
    color: AppColors.infoSurface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppColors.info.withOpacity(0.3),
      width: 1,
    ),
  );

  // ============== GLASS MORPHISM ==============
  static BoxDecoration glassMorphism = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
  );

  static BoxDecoration glassMorphismDark = BoxDecoration(
    color: Colors.black.withOpacity(0.3),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  );
}
