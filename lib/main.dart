// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:salah_shuttle/utils/dark_theme.dart';
import 'package:salah_shuttle/utils/light_theme.dart';
import 'package:salah_shuttle/utils/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
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
          // overlayColor & overlayOpacity are not supported — removed ✅
        ),
      ),
    );
  }
}
