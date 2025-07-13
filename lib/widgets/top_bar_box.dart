import 'package:flutter/material.dart';
import 'package:salah_shuttle/screens/date_screen.dart';

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

  void _onTapDown(_) => setState(() => _pressed = true);
  void _onTapUp(_) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Scaling factors
    final boxWidth = screenWidth * 0.16; // ~16% of screen width
    final boxHeight = boxWidth * 1.1;    // keep same aspect ratio
    final shadowOffsetY = boxHeight * 0.08;
    final shadowOffsetX = boxWidth * 0.08;
    final pressedOffsetY = _pressed ? shadowOffsetY : 0.0;
    final pressedOffsetX = _pressed ? shadowOffsetX : 0.0;

    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.2),
      child: GestureDetector(
        onTap: widget.onTap ??
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => widget.onScreenBuilder()),
              );
            },

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
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    height: boxHeight,
                    width: boxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xff1D1A1A),
                      borderRadius: BorderRadius.circular(8),
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
                      border: Border.all(width: 2, color: Colors.white),
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
