import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/custom_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme settings
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsTile(
            context: context,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark theme',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          
          const Divider(),
          
          // Account settings
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(
            context: context,
            title: 'Email',
            subtitle: SupabaseService().currentUser?.email ?? 'Not signed in',
          ),
          
          const SizedBox(height: 16),
          
          // Logout button
          CustomButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await SupabaseService().signOut();
              navigator.pushReplacementNamed(AppRoutes.login);
            },
            text: 'Logout',
            isOutlined: true,
            icon: Icons.logout,
          ),
          
          const SizedBox(height: 24),
          
          // App info
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            context: context,
            title: AppConstants.appName,
            subtitle: 'Version ${AppConstants.appVersion}',
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appDescription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
} 