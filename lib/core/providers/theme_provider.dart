import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants/app_constants.dart';

// Provider for ThemeMode
final themeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  SharedPreferences? _prefs;

  // Load saved theme mode
  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Retrieve saved theme mode, default to system
    final savedThemeMode = _prefs?.getString(AppConstants.themeModePrefKey);
    
    if (savedThemeMode == null) {
      state = AppConstants.isDarkModeDefault 
          ? ThemeMode.dark 
          : ThemeMode.light;
      return;
    }
    
    switch(savedThemeMode) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  // Update theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    // Save to SharedPreferences
    await _prefs?.setString(AppConstants.themeModePrefKey, themeMode.toString().split('.').last);
    
    // Update state
    state = themeMode;
  }

  // Toggle between light and dark mode
  Future<void> toggleThemeMode() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

// Extension to make ThemeMode more readable with Flutter prefix
extension Flutter on ThemeMode {
  static ThemeMode get lightTheme => ThemeMode.light;
  static ThemeMode get darkTheme => ThemeMode.dark;
  static ThemeMode get systemTheme => ThemeMode.system;
} 