// App Constants

class AppConstants {
  // App info
  static const String appName = 'Celenganku';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplikasi tabungan pribadi berbasis Flutter yang ringan, privat, dan mudah digunakan.';
  
  // App theme
  static const bool isDarkModeDefault = false;

  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String goalDetailRoute = '/goal';
  static const String settingsRoute = '/settings';
  
  // SharedPreferences keys
  static const String themeModePrefKey = 'themeMode';
  static const String userPrefKey = 'user';
  
  // Default values
  static const int defaultGoalsPerPage = 10;
  static const int defaultTransactionsPerPage = 15;
} 