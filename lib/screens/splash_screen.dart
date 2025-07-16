// screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salah_shuttle/styles/colors.dart';
import 'dart:async';
import 'dart:math'; // <-- IMPORT MATH LIBRARY FOR PI
import 'package:showcaseview/showcaseview.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _verticalAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // 🚀 Move rocket straight up
    _verticalAnimation = Tween<Offset>(
      begin: const Offset(0, 0), // Start at its original position
      end: const Offset(0, -5.0),   // Move 5 times its height upwards
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // Gives a nice acceleration
    ));

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ShowCaseWidget(
                builder: (context) => const HomeScreen(),
                blurValue: 1,
              ),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // This is the vertically-moving part
              SlideTransition(
                position: _verticalAnimation,
                // *** MODIFIED HERE: Rotate the rocket to point upwards ***
                child: Transform.rotate(
                  // Rotates the emoji by -45 degrees to make it vertical
                  angle: -pi / 4,
                  child:  Text(
                    '🚀',
                    style: GoogleFonts.poppins(fontSize: 80),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // The app name text
              Text(
                'Salah Shuttle',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}