import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class CustomRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CustomRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<CustomRefresh> createState() => _CustomRefreshState();
}

class _CustomRefreshState extends State<CustomRefresh> {
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
  GlobalKey<LiquidPullToRefreshState>();

  Future<void> _handleRefresh() {
    final completer = Completer<void>();

    Timer(const Duration(seconds: 1), () async {
      await widget.onRefresh();
      completer.complete();

      final isDark = Theme.of(context).brightness == Brightness.dark;

      Flushbar(
        message: "Prayer times updated successfully!",
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        borderRadius: BorderRadius.circular(16),
        borderWidth: 2.0,
        borderColor: isDark ? Colors.white : Colors.black,
        backgroundColor: isDark ? const Color(0xff1f4432) : const Color(0xff2a7321),
        shouldIconPulse: true,
        flushbarPosition: FlushbarPosition.BOTTOM,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInCubic,
        boxShadows: [
          BoxShadow(
            color: isDark ? Colors.black45 : const Color(0xff152313),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
        icon: const Icon(Icons.check_circle, color: Colors.white),
        messageColor: Colors.white,
      ).show(context);
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      showChildOpacityTransition: false,
      child: widget.child,
    );
  }
}
