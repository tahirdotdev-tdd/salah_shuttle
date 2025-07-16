import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:salah_shuttle/styles/colors.dart';
import 'package:salah_shuttle/styles/fonts.dart';
import 'package:salah_shuttle/widgets/hijri_date_tile.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class DateScreen extends StatefulWidget {
  const DateScreen({super.key});

  @override
  State<DateScreen> createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Flushbar(
      message: 'Date refreshed!',
      duration: const Duration(seconds: 3),
      backgroundColor: isDark ? Colors.teal : Colors.green,
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: BorderRadius.circular(16),
      borderWidth: 2.0,
      borderColor: Colors.black,
      boxShadows: [
        BoxShadow(
          color: isDark ? Colors.black54 : const Color(0xff152313),
          offset: const Offset(0, 3),
          blurRadius: 6,
        ),
      ],
      icon: const Icon(Icons.check_circle, color: Colors.white),
      messageColor: Colors.white,
      forwardAnimationCurve: Curves.easeOutBack,
    ).show(context);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : scaffoldBackgroundColor,
      body: LiquidPullToRefresh(
        onRefresh: _onRefresh,
        showChildOpacityTransition: false,
        color: isDark ? Colors.teal : Colors.green,
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : scaffoldBackgroundColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark
                  ? const Color(0xFF121212)
                  : scaffoldBackgroundColor,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              centerTitle: true,
              title: Text("Today's Islamic Date", style: standardFont(context)),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: HijriDateTile(
                      tileColor: isDark ? const Color(0xFF1E1E1E) : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
