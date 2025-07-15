import 'dart:ui';
import 'package:flutter/material.dart';

class NavTutorialOverlay extends StatefulWidget {
  final List<GlobalKey> itemKeys;
  final List<String> descriptions;
  final VoidCallback onFinish;

  const NavTutorialOverlay({
    required this.itemKeys,
    required this.descriptions,
    required this.onFinish,
    super.key,
  });

  @override
  State<NavTutorialOverlay> createState() => _NavTutorialOverlayState();
}

class _NavTutorialOverlayState extends State<NavTutorialOverlay> {
  int currentIndex = 0;

  Rect _getWidgetBounds(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      return position & renderBox.size;
    }
    return Rect.zero;
  }

  @override
  Widget build(BuildContext context) {
    final Rect bounds = _getWidgetBounds(widget.itemKeys[currentIndex]);

    return Stack(
      children: [
        // Blur background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),

        // Highlight box
        Positioned(
          left: bounds.left - 8,
          top: bounds.top - 8,
          width: bounds.width + 16,
          height: bounds.height + 16,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellowAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
            ),
          ),
        ),

        // Description and Button
        Positioned(
          bottom: 100,
          left: 30,
          right: 30,
          child: Column(
            children: [
              Text(
                widget.descriptions[currentIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (currentIndex < widget.itemKeys.length - 1) {
                    setState(() => currentIndex++);
                  } else {
                    widget.onFinish();
                  }
                },
                child: Text(currentIndex == widget.itemKeys.length - 1 ? 'Done' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
