import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salah_shuttle/widgets/top_bar_box.dart';

import '../screens/ayah_screen.dart';
import '../screens/date_screen.dart';
import '../screens/qiblah_screen.dart';
import '../screens/tasbeeh_screen.dart';
import '../utils/theme_provider.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.currentTheme == ThemeMode.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TopBarBox(label: '🗓️', onScreenBuilder: () => const DateScreen()),
        const SizedBox(width: 5),
        TopBarBox(label: '🕋', onScreenBuilder: () => const QiblahScreen()),
        const SizedBox(width: 5),
        TopBarBox(label: '📿', onScreenBuilder: () => const TasbeehScreen()),
        const SizedBox(width: 5),
        TopBarBox(label: '📖', onScreenBuilder: () => const AyahScreen()),
        const SizedBox(width: 5),

        /// 🌙/☀️ Theme Switch with AnimatedSwitcher
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: TopBarBox(
            key: ValueKey(isDark),
            label: isDark ? '☀️' : '🌙',
            onTap: () => themeProvider.toggleTheme(),
            onScreenBuilder: () => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
