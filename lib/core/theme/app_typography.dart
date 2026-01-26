import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FutsalPro Design System - Typography
/// Clean, modern typography with Inter for UI and Poppins for headings
class AppTypography {
  AppTypography._();

  // ============== BASE FONT FAMILIES ==============
  static String get _headingFamily => GoogleFonts.poppins().fontFamily!;
  static String get _bodyFamily => GoogleFonts.inter().fontFamily!;

  // ============== DISPLAY STYLES ==============
  static TextStyle displayLarge(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
    color: color,
  );

  static TextStyle displayMedium(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 45,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.16,
    color: color,
  );

  static TextStyle displaySmall(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
    color: color,
  );

  // ============== HEADLINE STYLES ==============
  static TextStyle headlineLarge(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: color,
  );

  static TextStyle headlineMedium(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: color,
  );

  static TextStyle headlineSmall(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: color,
  );

  // ============== TITLE STYLES ==============
  static TextStyle titleLarge(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: color,
  );

  static TextStyle titleMedium(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: color,
  );

  static TextStyle titleSmall(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: color,
  );

  // ============== BODY STYLES ==============
  static TextStyle bodyLarge(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: color,
  );

  static TextStyle bodyMedium(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: color,
  );

  static TextStyle bodySmall(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: color,
  );

  // ============== LABEL STYLES ==============
  static TextStyle labelLarge(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: color,
  );

  static TextStyle labelMedium(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    color: color,
  );

  static TextStyle labelSmall(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
    color: color,
  );

  // ============== BUTTON STYLES ==============
  static TextStyle buttonLarge(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.5,
    color: color,
  );

  static TextStyle buttonMedium(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.43,
    color: color,
  );

  static TextStyle buttonSmall(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    color: color,
  );

  // ============== SPECIAL STYLES ==============
  static TextStyle caption(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: color,
  );

  static TextStyle overline(Color color) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.6,
    color: color,
  );

  static TextStyle monospace(Color color) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
    color: color,
  );

  // ============== NUMBER/METRIC STYLES ==============
  static TextStyle metricLarge(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    height: 1.1,
    color: color,
  );

  static TextStyle metricMedium(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
    color: color,
  );

  static TextStyle metricSmall(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
    color: color,
  );

  // ============== PRICE STYLES ==============
  static TextStyle priceLarge(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: color,
  );

  static TextStyle priceMedium(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: color,
  );

  static TextStyle priceSmall(Color color) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: color,
  );
}
