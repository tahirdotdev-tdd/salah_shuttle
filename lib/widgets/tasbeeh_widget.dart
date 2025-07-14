import 'package:flutter/material.dart';

class TasbeehWidget extends StatefulWidget {
  const TasbeehWidget({super.key});

  @override
  State<TasbeehWidget> createState() => _TasbeehWidgetState();
}

class _TasbeehWidgetState extends State<TasbeehWidget> {
  int count = 0;

  counter() {
    setState(() {
      count++;
    });
  }

  reset() {
    setState(() {
      count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = isDark ? Colors.black : Colors.green;
    final textColor = isDark ? Colors.black : Colors.black;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: isDark ? Colors.white : Colors.black),
            borderRadius: BorderRadius.circular(100),
            color: mainColor,
          ),
          child: Container(
            alignment: Alignment.center,
            height: 10,
            width: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                color: textColor,
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            height: 180,
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: isDark ? Colors.white : Colors.black),
              color: mainColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: counter,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                    foregroundColor: mainColor,
                  ),
                  child: const Text(
                    "+",
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
