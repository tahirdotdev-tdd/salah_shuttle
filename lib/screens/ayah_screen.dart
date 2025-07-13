import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:salah_shuttle/widgets/copy_button.dart';
import 'package:flutter/services.dart';

import '../styles/colors.dart';
import '../styles/fonts.dart';
import '../widgets/daily_ayah_tile.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class AyahScreen extends StatefulWidget {
  const AyahScreen({super.key});

  @override
  State<AyahScreen> createState() => _AyahScreenState();
}

class _AyahScreenState extends State<AyahScreen> {
  String? arabicAyah;
  String? englishAyah;
  String? reference;
  bool isLoading = true;
  String? error;

  static const int totalAyat = 6236;
  static const String arabicEdition = 'ar.alafasy';
  static const String englishEdition = 'en.asad';

  @override
  void initState() {
    super.initState();
    fetchRandomAyah();
  }

  Future<void> fetchRandomAyah({bool showFlushbar = false}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final random = Random();
    final ayahNumber = random.nextInt(totalAyat) + 1;

    final url =
        'http://api.alquran.cloud/v1/ayah/$ayahNumber/editions/$arabicEdition,$englishEdition';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final editions = data['data'] as List;
          final arabic = editions.firstWhere((e) => e['edition']['identifier'] == arabicEdition);
          final english = editions.firstWhere((e) => e['edition']['identifier'] == englishEdition);
          setState(() {
            arabicAyah = arabic['text'];
            englishAyah = english['text'];
            reference = "${arabic['surah']['number']}:${arabic['numberInSurah']}";
            isLoading = false;
          });

          if (showFlushbar) {
            Flushbar(
              message: "Daily ayah refreshed!",
              duration: const Duration(seconds: 3),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.teal
                  : Colors.green,
              flushbarStyle: FlushbarStyle.FLOATING,
              flushbarPosition: FlushbarPosition.BOTTOM,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderRadius: BorderRadius.circular(16),
              borderWidth: 2.0,
              borderColor: Colors.black,
              boxShadows: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : const Color(0xff152313),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
              icon: const Icon(Icons.refresh, color: Colors.white),
              messageColor: Colors.white,
            ).show(context);
          }
        } else {
          setState(() {
            error = 'Error: ${data['status']}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Network error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Exception: $e';
        isLoading = false;
      });
    }
  }

  void _copyAyahToClipboard() {
    if (arabicAyah != null && englishAyah != null && reference != null) {
      final ayahText = "$arabicAyah\n\n$englishAyah\n\n📖 $reference";

      Clipboard.setData(ClipboardData(text: ayahText));

      Flushbar(
        message: 'Ayah copied to clipboard!',
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.teal
            : Colors.green,
        flushbarStyle: FlushbarStyle.FLOATING,
        flushbarPosition: FlushbarPosition.BOTTOM,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        borderRadius: BorderRadius.circular(16),
        borderWidth: 2.0,
        borderColor: Colors.black,
        boxShadows: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : const Color(0xff152313),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
        icon: const Icon(Icons.check_circle, color: Colors.white),
        messageColor: Colors.white,
        mainButton: TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: ayahText));
          },
          child: const Text(
            'Copy Again',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ).show(context);
    }
  }

  Future<void> _refreshAyah() async {
    await fetchRandomAyah(showFlushbar: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : scaffoldBackgroundColor,
      body: LiquidPullToRefresh(
        onRefresh: _refreshAyah,
        showChildOpacityTransition: false,
        color: isDark ? Colors.teal : Colors.green,
        backgroundColor: isDark ? const Color(0xFF121212) : scaffoldBackgroundColor,
        height: 80,
        animSpeedFactor: 2,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF121212) : scaffoldBackgroundColor,
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_outlined,
                    color: isDark ? Colors.white : Colors.black),
              ),
              title: Text("Daily Ayah", style: standardFont()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: isLoading
                          ? LoadingAnimationWidget.staggeredDotsWave(
                          color: isDark ? Colors.teal : Colors.green, size: 100)
                          : error != null
                          ? Text(error!,
                          style: TextStyle(
                              color: isDark ? Colors.red[200] : Colors.red))
                          : DailyAyahTile(
                        tileColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        arabicAyah: arabicAyah!,
                        englishAyah: englishAyah!,
                        reference: reference!,
                      ),
                    ),
                    const SizedBox(height: 60),
                    if (!isLoading && error == null)
                      CopyButton(label: "Copy", onTap: _copyAyahToClipboard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
