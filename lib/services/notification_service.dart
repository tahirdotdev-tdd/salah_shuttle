// NO LONGER NEEDED: import 'dart:math' as Importance;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data; // Good practice to alias
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Use the aliased import for clarity
    tz_data.initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    // This is for Android 13 and above
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'salah_channel_id',
          'Salah Reminders',
          // NOTE: channelDescription may not exist in very old versions.
          // If you get another error here, you may have to remove it too.
          channelDescription: 'Channel for prayer time notifications.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),

      // ✅ CORRECTED: Using the old parameter that your version expects
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // ❌ REMOVED: The uiLocalNotificationDateInterpretation parameter,
      // as it does not exist in your old package version.
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
  Future<void> showWelcomeNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'startup_channel_id',
      'Startup Notification',
      channelDescription: 'Channel for welcome or startup messages.',
      importance: Importance.low,
      priority: Priority.low,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      9999, // Arbitrary unique ID
      'Salah Shuttle is active',
      'We’ll notify you for each prayer daily.',
      notificationDetails,
    );
  }

}
