import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedAppBarTitle extends StatefulWidget {
  const AnimatedAppBarTitle({super.key});

  @override
  State<AnimatedAppBarTitle> createState() => _AnimatedAppBarTitleState();
}

class _AnimatedAppBarTitleState extends State<AnimatedAppBarTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _diagonalAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _diagonalAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 1.5), // Bottom-left
      end: const Offset(1.5, -1.5),   // Top-right
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Salah Shuttle',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        ClipRect(
          child: SizedBox(
            width: 32,
            height: 32,
            child: SlideTransition(
              position: _diagonalAnimation,
              child: const Text(
                '🚀',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
