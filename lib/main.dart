import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salah_shuttle/services/background_service.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:salah_shuttle/services/notification_service.dart';
import 'package:salah_shuttle/utils/dark_theme.dart';
import 'package:salah_shuttle/utils/light_theme.dart';
import 'package:salah_shuttle/utils/theme_provider.dart';
import 'screens/home_screen.dart';

// The main function now needs to be async.
Future<void> main() async {
  // This is required to ensure that plugin services are initialized before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // --- Initialize Services ---
  await NotificationService().init();
  await AndroidAlarmManager.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );

  // --- Schedule the Daily Alarm ---
  const int dailyTaskId = 0; // A unique ID for our task
  await AndroidAlarmManager.periodic(
    const Duration(hours: 24), // Run once every day
    dailyTaskId,
    fetchAndScheduleDaily, // The top-level function to run
    startAt: DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 2, 0), // Schedule it for 2:00 AM daily
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true, // Ensures the alarm is rescheduled when the phone reboots
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.currentTheme == ThemeMode.dark;

    return AnimatedTheme(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      data: isDark ? darkTheme : lightTheme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Salah Shuttle',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.currentTheme,
        home: ShowCaseWidget(
          builder: (context) => const HomeScreen(),
          blurValue: 1,
        ),
      ),
    );
  }
}