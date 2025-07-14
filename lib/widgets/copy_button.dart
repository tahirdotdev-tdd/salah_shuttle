import 'package:flutter/material.dart';

class CopyButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const CopyButton({super.key, required this.label, required this.onTap});

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _pressed = false;

  void _onTapDown(_) => setState(() => _pressed = true);
  void _onTapUp(_) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final boxWidth = screenWidth * 0.5;
    final boxHeight = 50.0;
    final shadowOffsetY = 6.0;
    final shadowOffsetX = 6.0;
    final offsetX = _pressed ? shadowOffsetX : 0.0;
    final offsetY = _pressed ? shadowOffsetY : 0.0;

    final Color buttonColor = isDark ? const Color(0xff2B2B2B) : const Color(0xff1D1A1A);
    final Color textColor = isDark ? Colors.white : Colors.white;
    final Color shadowColor = isDark ? Colors.black : const Color(0xff1D1A1A);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        height: boxHeight + shadowOffsetY,
        width: boxWidth + shadowOffsetX,
        child: Stack(
          children: [
            // Shadow layer
            Positioned(
              right: 0,
              top: shadowOffsetY,
              child: Container(
                height: boxHeight,
                width: boxWidth,
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3, color: isDark ? Colors.white : Colors.black),
                ),
              ),
            ),

            // Foreground button
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(offsetX, offsetY, 0),
                height: boxHeight,
                width: boxWidth,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 2, color: Colors.white),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
