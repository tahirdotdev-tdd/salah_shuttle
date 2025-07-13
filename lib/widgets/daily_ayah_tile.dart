import 'package:flutter/material.dart';

class DailyAyahTile extends StatefulWidget {
  final Color tileColor;
  final String arabicAyah;
  final String englishAyah;
  final String reference;

  const DailyAyahTile({
    super.key,
    required this.tileColor,
    required this.arabicAyah,
    required this.englishAyah,
    required this.reference,
  });

  @override
  State<DailyAyahTile> createState() => _DailyAyahTileState();
}

class _DailyAyahTileState extends State<DailyAyahTile> {
  bool _pressed = false;

  void _onTapDown(_) => setState(() => _pressed = true);
  void _onTapUp(_) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final tileWidth = width * 0.9;
    final tileHeight = tileWidth * 0.75;
    final shadowOffset = tileHeight * 0.065;
    final offset = _pressed ? shadowOffset : 0.0;

    final borderColor = isDark ? Colors.white : Colors.black;
    final tileBgColor = isDark ? const Color(0xFF1e1e1e) : Colors.white;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        height: tileHeight + shadowOffset,
        width: tileWidth,
        child: Stack(
          children: [
            // Shadow/Back layer
            Positioned(
              right: 0,
              top: shadowOffset,
              child: Container(
                height: tileHeight,
                width: tileWidth * 0.96,
                decoration: BoxDecoration(
                  color: tileBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 3, color: borderColor),
                ),
              ),
            ),

            // Foreground tile with press animation
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(offset, offset, 0),
                child: Container(
                  height: tileHeight,
                  width: tileWidth * 0.965,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tileBgColor,
                    border: Border.all(width: 3, color: borderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SelectableText(
                            widget.arabicAyah,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            widget.englishAyah,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            '📖 ${widget.reference}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[300] : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
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
