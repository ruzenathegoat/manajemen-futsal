import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

/// FutsalPro Theme Provider
/// Manages app-wide theme state with persistence
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  
  bool _isDarkMode = true; // Default to dark mode for premium look
  bool _isInitialized = false;
  
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadTheme();
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    // Persist preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  /// Set specific theme mode
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true; // Default dark mode
    _isInitialized = true;
    notifyListeners();
  }

  /// Get the current theme data
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  /// Light theme using the new design system
  ThemeData get lightTheme => AppTheme.lightTheme;

  /// Dark theme using the new design system
  ThemeData get darkTheme => AppTheme.darkTheme;
}