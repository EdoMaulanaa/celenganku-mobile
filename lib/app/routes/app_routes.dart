import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/goals/screens/goal_detail_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

// Class untuk mengelola route paths
class AppRoutes {
  // Route names
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String goalDetail = '/goal';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';

  // Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => const GoalsScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      default:
        // Handle goal detail with ID parameter
        if (settings.name?.startsWith('$goalDetail/') ?? false) {
          final goalId = settings.name!.split('/')[2];
          return MaterialPageRoute(
            builder: (context) => GoalDetailScreen(goalId: goalId),
          );
        }
        
        // Fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => const GoalsScreen(),
        );
    }
  }

  // Helper method for navigating to goal detail
  static void navigateToGoalDetail(BuildContext context, String goalId) {
    Navigator.pushNamed(context, '$goalDetail/$goalId');
  }
}
