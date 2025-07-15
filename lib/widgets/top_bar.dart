import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart'; // 1. Import the package
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
  // Your keys are already perfectly set up!
  final List<GlobalKey> _itemKeys = List.generate(5, (_) => GlobalKey());

  // We no longer need _showTutorial or the custom overlay logic.
  // The showcaseview package handles the overlay for us.

  @override
  void initState() {
    super.initState();
    // 2. Use WidgetsBinding to reliably start the showcase after the UI is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartShowcase());
  }

  /// Checks if the tutorial has been shown and starts the showcase if not.
  Future<void> _checkAndStartShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final bool tutorialShown = prefs.getBool('topBarTutorialShown') ?? false;

    // Check if the widget is still mounted before starting the showcase.
    if (!tutorialShown && mounted) {
      // 3. This one line starts the entire showcase sequence.
      ShowCaseWidget.of(context).startShowCase(_itemKeys);
      // Mark the tutorial as seen.
      await prefs.setBool('topBarTutorialShown', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.currentTheme == ThemeMode.dark;

    // We can define our showcase titles and descriptions here for clarity.
    final List<String> titles = [
      'Islamic Date',
      'Qiblah Direction',
      'Tasbeeh Counter',
      'Daily Ayah',
      'Dark Mode'
    ];
    final List<String> descriptions = [
      'Tap here to see today\'s Islamic date and other useful info.',
      'This button helps you find the direction of the Qiblah for prayer.',
      'Use the digital counter for your daily Tasbeeh and Dhikr.',
      'Get a new verse from the Qur\'an for daily inspiration and reflection.',
      'Easily switch between the light and dark theme for your comfort.',
    ];

    // 4. Wrap each TopBarBox with a Showcase widget.
    // The Stack and _showTutorial logic is no longer needed.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Date Screen Box
        Showcase(
          key: _itemKeys[0],
          title: titles[0],
          description: descriptions[0],
          targetPadding: EdgeInsets.all(10),
          targetShapeBorder: CircleBorder(),
          child: TopBarBox(label: '🗓️', onScreenBuilder: () => const DateScreen()),
        ),
        const SizedBox(width: 5),

        // Qiblah Screen Box
        Showcase(
          key: _itemKeys[1],
          title: titles[1],
          description: descriptions[1],
          targetPadding: EdgeInsets.all(10),
          targetShapeBorder: CircleBorder(),
          child: TopBarBox(label: '🕋', onScreenBuilder: () => const QiblahScreen()),
        ),
        const SizedBox(width: 5),

        // Tasbeeh Screen Box
        Showcase(
          key: _itemKeys[2],
          title: titles[2],
          description: descriptions[2],
          targetPadding: EdgeInsets.all(10),
          targetShapeBorder: CircleBorder(),
          child: TopBarBox(label: '📿', onScreenBuilder: () => const TasbeehScreen()),
        ),
        const SizedBox(width: 5),

        // Ayah Screen Box
        Showcase(
          key: _itemKeys[3],
          title: titles[3],
          description: descriptions[3],
          targetPadding: EdgeInsets.all(10),
          targetShapeBorder: CircleBorder(),
          child: TopBarBox(label: '📖', onScreenBuilder: () => const AyahScreen()),
        ),
        const SizedBox(width: 5),

        // Theme Toggle Box
        Showcase(
          key: _itemKeys[4],
          title: titles[4],
          description: descriptions[4],
          targetPadding: EdgeInsets.all(10),
          targetShapeBorder: CircleBorder(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: TopBarBox(
              // Add a unique key to the child inside AnimatedSwitcher for stability
              key: ValueKey<bool>(isDark),
              label: isDark ? '☀️' : '🌙',
              onTap: () => themeProvider.toggleTheme(),
              onScreenBuilder: () => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}