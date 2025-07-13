import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salah_shuttle/screens/ayah_screen.dart';
import 'package:salah_shuttle/screens/date_screen.dart';
import 'package:salah_shuttle/screens/qiblah_screen.dart';
import 'package:salah_shuttle/screens/tasbeeh_screen.dart';
import 'package:salah_shuttle/widgets/top_bar_box.dart';
import '../utils/theme_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TopBarBox(label: '📅', onScreenBuilder: () => const DateScreen()),
        const SizedBox(width: 5),
        TopBarBox(label: '🧭', onScreenBuilder: () => const QiblahScreen()),
        const SizedBox(width: 5),
        TopBarBox(label: '🔄️', onScreenBuilder: () => const TasbeehScreen()),
        const SizedBox(width: 5),
        TopBarBox(label: '☀️', onScreenBuilder: () => const AyahScreen()),
        const SizedBox(width: 5),
        TopBarBox(
          label: isDark ? '☀️' : '🌙',
          onTap: () => themeProvider.toggleTheme(),
          onScreenBuilder: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
