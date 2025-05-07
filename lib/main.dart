import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/supabase_service.dart';
import 'app/constants/app_constants.dart';
import 'core/providers/onboarding_provider.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load();
  
  // Initialize Supabase
  await SupabaseService().initialize();
  
  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme changes
    final themeMode = ref.watch(themeProvider);
    
    // Check if onboarding is completed
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: onboardingCompleted.when(
        loading: () => AppRoutes.home, // Show home as fallback while loading
        error: (_, __) => AppRoutes.home, // Show home if there's an error
        data: (completed) => completed ? AppRoutes.home : AppRoutes.onboarding,
      ),
    );
  }
}
