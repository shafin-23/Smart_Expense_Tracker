
import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;
  static const String _channelId = 'expense_tracker_notifications';

  static bool _initialized = false;
  static Timer? _windowsReminderTimer;

  static tz.Location? _dhaka;

  // Initialize notification plugin.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    _dhaka = tz.getLocation('Asia/Dhaka');

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final windowsSettings = WindowsInitializationSettings(
      appName: 'Smart Expense Tracker',
      appUserModelId: 'com.example.expense_tracker',
      guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
    );

    _initialized = true;
  }

  // Enable notifications and schedule daily reminder.
  static Future<bool> enableNotifications() async {
    await initialize();

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final notificationPermission =
        await androidPlugin.requestNotificationsPermission();

        if (notificationPermission == false) {
          return false;
        }

        final exactAlarmPermission =
        await androidPlugin.requestExactAlarmsPermission();

        await _scheduleAndroidReminder(
          exactAlarmGranted: exactAlarmPermission == true,
        );
      }
    } else if (Platform.isWindows) {
      _scheduleWindowsReminder();
    }

    return true;
  }

  // Disable notifications.
  static Future<void> disableNotifications() async {
    _windowsReminderTimer?.cancel();
    _windowsReminderTimer = null;

    if (!_initialized) return;

    await _plugin.cancel(id: _dailyReminderId);
  }

  // Schedule Android reminder every day at 10 PM Bangladesh time.
  static Future<void> _scheduleAndroidReminder({
    required bool exactAlarmGranted,
  }) async {
    final location = _dhaka!;
    final now = tz.TZDateTime.now(location);

    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      22,
      0,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.cancel(id: _dailyReminderId);

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'Daily Expense Reminder',
      body: 'আজকের আয়-ব্যয়ের হিসাবটি যোগ করতে ভুলবে না!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Expense Tracker Reminders',
          channelDescription: 'Daily expense entry reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: exactAlarmGranted
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Windows reminder while the application is running.
  static void _scheduleWindowsReminder() {
    _windowsReminderTimer?.cancel();

    final location = _dhaka!;
    final now = tz.TZDateTime.now(location);

    var nextReminder = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      22,
      0,
    );

    if (!nextReminder.isAfter(now)) {
      nextReminder = nextReminder.add(const Duration(days: 1));
    }

    final duration = nextReminder.difference(now);

    _windowsReminderTimer = Timer(duration, () async {
      await showDailyReminder();
      _scheduleWindowsReminder();
    });
  }

  // Show daily reminder immediately.
  static Future<void> showDailyReminder() async {
    await initialize();

    await _plugin.show(
      id: _dailyReminderId,
      title: 'Daily Expense Reminder',
      body: 'আজকের আয়-ব্যয়ের হিসাবটি যোগ করতে ভুলবে না!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Expense Tracker Reminders',
          channelDescription: 'Daily expense entry reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Notify when a category budget is exceeded.
  static Future<void> showBudgetExceeded({
    required int budgetId,
    required String category,
    required double spent,
    required double limit,
    required String currencySymbol,
  }) async {
    await initialize();

    await _plugin.show(
      id: 2000 + budgetId,
      title: 'Budget Limit Exceeded!',
      body:
      '$category budget exceeded. Spent: $currencySymbol${spent.toStringAsFixed(2)}, Limit: $currencySymbol${limit.toStringAsFixed(2)}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Expense Tracker Reminders',
          channelDescription: 'Budget limit alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
