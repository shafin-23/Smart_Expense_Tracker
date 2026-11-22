import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_preferences_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _currency = 'BDT (৳)';
  String _name = '';

  bool _notificationsEnabled = false;
  bool _isUpdatingNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final appPreferences = ref.read(appPreferencesProvider);

    setState(() {
      _notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;

      _currency = appPreferences.currency;
      _name = appPreferences.profileName;
    });
  }

  Future<void> _changeCurrency() async {
    const currencies = [
      'BDT (৳)',
      'USD (\$)',
      'EUR (€)',
      'GBP (£)',
      'INR (₹)',
    ];

    final selectedCurrency = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: RadioGroup<String>(
            groupValue: _currency,
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: currencies.map((currency) {
                return RadioListTile<String>(
                  title: Text(currency),
                  value: currency,
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCurrency == null || !mounted) return;

    await ref
        .read(appPreferencesProvider.notifier)
        .updateCurrency(selectedCurrency);

    if (!mounted) return;

    setState(() {
      _currency = selectedCurrency;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Currency updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editProfile() async {
    final controller = TextEditingController(text: _name);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || !mounted) return;

    await ref
        .read(appPreferencesProvider.notifier)
        .updateProfileName(newName);

    if (!mounted) return;

    setState(() {
      _name = newName;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_isUpdatingNotifications) return;

    setState(() {
      _isUpdatingNotifications = true;
    });

    try {
      if (value) {
        final enabled =
        await NotificationService.enableNotifications();

        if (!enabled) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notification permission was not granted.',
              ),
            ),
          );

          return;
        }
      } else {
        await NotificationService.disableNotifications();
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('notifications_enabled', value);

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Notifications enabled'
                : 'Notifications disabled',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingNotifications = false;
        });
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Smart Expense Tracker stores your financial records '
              'locally on your device. Your personal expense data '
              'is used to display your financial information and '
              'generate reports.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'How to use Smart Expense Tracker:\n\n'
              '1. Add your income and expenses.\n'
              '2. Track your balance from Dashboard.\n'
              '3. View spending activity in Analytics.\n'
              '4. Set monthly budgets.\n'
              '5. Manage your preferences from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Expense Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 40,
        color: AppColors.primary,
      ),
      applicationLegalese: '© 2026 Smart Expense Tracker',
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesProvider);
    final themeMode = ref.watch(themeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Manage your account and preferences',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 25),

            // Profile Section
            _sectionTitle('Profile'),

            const SizedBox(height: 12),

            _settingsCard(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.surfaceLight,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  preferences.profileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Profile Name'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _editProfile,
              ),
            ),

            const SizedBox(height: 25),

            // Preferences Section
            _sectionTitle('Preferences'),

            const SizedBox(height: 12),

            _settingsCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.currency_exchange,
                      color: AppColors.primary,
                    ),
                    title: const Text('Currency'),
                    subtitle: Text(preferences.currency),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changeCurrency,
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    secondary: const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: const Text(
                      'Change app appearance',
                    ),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref
                          .read(themeProvider.notifier)
                          .toggleTheme(value);
                    },
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Notifications'),
                    subtitle: const Text(
                      'Daily expense reminders',
                    ),
                    value: _notificationsEnabled,
                    onChanged: _isUpdatingNotifications
                        ? null
                        : _toggleNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // General Section
            _sectionTitle('General'),

            const SizedBox(height: 12),

            _settingsCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showPrivacyPolicy,
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: AppColors.primary,
                    ),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showHelp,
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showAbout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'Smart Expense Tracker v1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: child,
    );
  }
}
