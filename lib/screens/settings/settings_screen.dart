
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceLight,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shafin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Personal Account',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Preferences',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          _settingTile(
            Icons.dark_mode_outlined,
            'Appearance',
            'Dark Mode',
          ),

          _settingTile(
            Icons.currency_exchange,
            'Currency',
            'BDT (৳)',
          ),

          _settingTile(
            Icons.notifications_none,
            'Notifications',
            'Manage notifications',
          ),

          const SizedBox(height: 25),

          const Text(
            'Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          _settingTile(
            Icons.lock_outline,
            'Privacy & Security',
            'Manage your account',
          ),

          _settingTile(
            Icons.help_outline,
            'Help & Support',
            'Get assistance',
          ),

          _settingTile(
            Icons.info_outline,
            'About App',
            'Version 1.0.0',
          ),
        ],
      ),
    );
  }

  Widget _settingTile(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
    );
  }
}
