
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service.
  await NotificationService.initialize();

  // Restore notification settings saved by the user.
  final prefs = await SharedPreferences.getInstance();
  final notificationsEnabled =
      prefs.getBool('notifications_enabled') ?? false;

  if (notificationsEnabled) {
    await NotificationService.enableNotifications();
  }

  runApp(
    const ProviderScope(
      child: SmartExpenseApp(),
    ),
  );
}
