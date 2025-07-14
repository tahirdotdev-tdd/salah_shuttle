import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salah_shuttle/styles/colors.dart';
import 'package:salah_shuttle/styles/fonts.dart';
import 'package:salah_shuttle/widgets/tasbeeh_widget.dart';

class TasbeehScreen extends StatelessWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        title: Text("Tasbeeh", style: standardFont(context)),
        backgroundColor: isDark ? const Color(0xFF121212) : scaffoldBackgroundColor,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF121212) : scaffoldBackgroundColor,
      body: const Center(child: TasbeehWidget()),
    );
  }
}
