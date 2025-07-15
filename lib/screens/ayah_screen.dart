import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:salah_shuttle/widgets/copy_button.dart';

import '../styles/colors.dart';
import '../styles/fonts.dart';
import '../widgets/daily_ayah_tile.dart';

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
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  static const int totalAyat = 6236;
  static const String arabicEdition = 'ar.alafasy';
  static const String englishEdition = 'en.asad';

  @override
  void initState() {
    super.initState();
    // Subscribe to connectivity changes
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    // Fetch the initial Ayah
    fetchRandomAyah();
  }

  @override
  void dispose() {
    // Cancel subscription to prevent memory leaks
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// Automatically fetches a new Ayah if connection is restored and there was a previous error.
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (!result.contains(ConnectivityResult.none) && error != null) {
      fetchRandomAyah();
    }
  }

  /// Fetches a random Ayah from the API, with robust error and connectivity handling.
  Future<void> fetchRandomAyah({bool showFlushbar = false}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    // 1. Check for internet connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        setState(() {
          error = "No internet connection. Please connect to a network to fetch an Ayah.";
          isLoading = false;
        });
      }
      return; // Stop execution
    }

    final random = Random();
    final ayahNumber = random.nextInt(totalAyat) + 1;
    final url = 'http://api.alquran.cloud/v1/ayah/$ayahNumber/editions/$arabicEdition,$englishEdition';

    try {
      // 2. Make the API call with a timeout
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (!mounted) return; // Ensure the widget is still in the tree

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
            _showRefreshFlushbar();
          }
        } else {
          setState(() => error = 'API Error: ${data['status']}');
        }
      } else {
        setState(() => error = 'Failed to load data. Server responded with status code: ${response.statusCode}');
      }
    } on SocketException {
      if (mounted) setState(() => error = "No internet connection. Please check your network and try again.");
    } on TimeoutException {
      if (mounted) setState(() => error = "The request timed out. Please try again.");
    } catch (e) {
      if (mounted) setState(() => error = 'An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _copyAyahToClipboard() {
    if (arabicAyah != null && englishAyah != null && reference != null) {
      final ayahText = "$arabicAyah\n\n$englishAyah\n\n📖 $reference";
      Clipboard.setData(ClipboardData(text: ayahText));
      _showCopyFlushbar(ayahText);
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
                icon: Icon(Icons.arrow_back_ios_new_outlined, color: isDark ? Colors.white : Colors.black),
              ),
              title: Text("Daily Ayah", style: standardFont(context)),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildContent(isDark), // Central content widget
                    if (!isLoading && error == null) ...[
                      const SizedBox(height: 60),
                      CopyButton(label: "Copy", onTap: _copyAyahToClipboard),
                    ],
                    const SizedBox(height: 20), // Padding at the bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main content area: loading indicator, error message, or Ayah tile.
  Widget _buildContent(bool isDark) {
    if (isLoading) {
      return LoadingAnimationWidget.staggeredDotsWave(
        color: isDark ? Colors.teal : Colors.green,
        size: 100,
      );
    }
    if (error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.red[200] : Colors.red, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fetchRandomAyah,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.teal.shade700 : Colors.green.shade700,
            ),
          )
        ],
      );
    }
    return DailyAyahTile(
      tileColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      arabicAyah: arabicAyah!,
      englishAyah: englishAyah!,
      reference: reference!,
    );
  }

  // Extracted Flushbar methods for cleaner code
  void _showRefreshFlushbar() {
    Flushbar(
      message: "Daily ayah refreshed!",
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.teal : Colors.green,
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(Icons.refresh, color: Colors.white),
      messageColor: Colors.white,
    ).show(context);
  }

  void _showCopyFlushbar(String ayahText) {
    Flushbar(
      message: 'Ayah copied to clipboard!',
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.teal : Colors.green,
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      messageColor: Colors.white,
      mainButton: TextButton(
        onPressed: () => Clipboard.setData(ClipboardData(text: ayahText)),
        child: const Text('Copy Again', style: TextStyle(color: Colors.white)),
      ),
    ).show(context);
  }
}