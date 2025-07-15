import 'package:flutter/material.dart';

// Make sure to import your custom route transition
// import 'package:salah_shuttle/transitions/slide_right_route.dart'; 

class TopBarBox extends StatefulWidget {
  final String label;
  final Widget Function() onScreenBuilder;
  final VoidCallback? onTap;

  const TopBarBox({
    super.key,
    required this.label,
    required this.onScreenBuilder,
    this.onTap,
  });

  @override
  State<TopBarBox> createState() => _TopBarBoxState();
}

class _TopBarBoxState extends State<TopBarBox> {
  bool _pressed = false;

  void _onTapDown(_) {
    setState(() => _pressed = true);
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  /// This method now orchestrates the animation and navigation.
  Future<void> _onTapUp(_) async {
    // A small delay to ensure the "pressed" state is visually perceived by the user.
    // The press animation itself has a duration of 100ms.
    await Future.delayed(const Duration(milliseconds: 100));

    // Check if the widget is still in the widget tree before proceeding.
    if (!mounted) return;

    // Trigger the "un-press" animation.
    setState(() => _pressed = false);

    // Check if this is a navigation box or the toggle box.
    if (widget.onTap == null) {
      // This is a navigation box.
      // Wait for the "un-press" animation to complete before navigating.
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        Navigator.push(
          context,
          SlideRightPageRoute(page: widget.onScreenBuilder()),
        );
      }
    } else {
      // This is the toggle box. Execute its onTap callback immediately.
      // The un-press animation will happen concurrently.
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final boxWidth = screenWidth * 0.16;
    final boxHeight = boxWidth * 1.1;
    final shadowOffsetY = boxHeight * 0.08;
    final shadowOffsetX = boxWidth * 0.08;
    final pressedOffsetY = _pressed ? shadowOffsetY : 0.0;
    final pressedOffsetX = _pressed ? shadowOffsetX : 0.0;

    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.2),
      child: GestureDetector(
        // We now handle all logic in the specific down/up/cancel callbacks.
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox(
          height: boxHeight + shadowOffsetY,
          width: boxWidth + shadowOffsetX,
          child: Stack(
            children: [
              // Shadow Container
              Positioned(
                right: 0,
                top: shadowOffsetY,
                child: Container(
                  height: boxHeight,
                  width: boxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xff1D1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 3,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              // Front Container
              Positioned(
                left: 0,
                top: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.translationValues(
                    pressedOffsetX,
                    pressedOffsetY,
                    0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: boxHeight,
                    width: boxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xff1D1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 3,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    child: FittedBox(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// A custom PageRoute that transitions by sliding the new page in from the right.
class SlideRightPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRightPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final curve = Curves.easeOut;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}