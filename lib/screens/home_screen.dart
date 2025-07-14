import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


import 'package:salah_shuttle/widgets/custom_refresh.dart';
import 'package:salah_shuttle/widgets/salah_tile.dart';
import 'package:salah_shuttle/widgets/top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Map<String, String> prayerTimes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToConnectivity(); // For real-time changes
    _fetchPrayerTimes(); // For initial load
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Shows a custom AlertDialog for the initial offline state.
  void _showNoInternetDialog() {
    // This ensures the dialog is shown only after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false, // User must interact with the dialog
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).cardColor,
          titlePadding: const EdgeInsets.only(top: 16, left: 20, right: 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'No Internet Connection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: const Text(
            'Prayer times are fetched locally.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    });
  }

  /// Shows a SnackBar for subsequent, real-time connectivity changes.
  void _showOfflineSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        content: const Text(
          'You are now offline. Times are calculated locally.',
          style: TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.tealAccent,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Listens for connectivity changes while the app is running.
  void _listenToConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Use the less-intrusive SnackBar for changes that happen after the initial load.
      if (results.contains(ConnectivityResult.none) && !isLoading) {
        _showOfflineSnackbar();
      }
    });
  }

  /// Fetches location and calculates prayer times on initial load or refresh.
  Future<void> _fetchPrayerTimes() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    // Use the AlertDialog for the initial check.
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception("Location services are disabled.");
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      final coordinates = Coordinates(pos.latitude, pos.longitude);
      final params = CalculationMethod.karachi();
      params.madhab = Madhab.hanafi;
      final date = DateTime.now();
      final times = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params);

      if (!mounted) return;

      setState(() {
        prayerTimes = {
          'fajr': _formatTime(times.fajr!),
          'dhuhr': _formatTime(times.dhuhr!),
          'asr': _formatTime(times.asr!),
          'maghrib': _formatTime(times.maghrib!),
          'isha': _formatTime(times.isha!),
        };
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        prayerTimes = {
          'fajr': 'Error',
          'dhuhr': 'Error',
          'asr': 'Error',
          'maghrib': 'Error',
          'isha': 'Error',
        };
        isLoading = false;
      });
    }
  }

  String _formatTime(DateTime dt) {
    return TimeOfDay.fromDateTime(dt.toLocal()).format(context);
  }

  Future<void> _handleRefresh() async {
    await _fetchPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff3e8cb),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: isLoading
            ? Center(
          key: const ValueKey('loading'),
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: isDark ? Colors.teal : Colors.green,
            size: 100,
          ),
        )
            : HomeContent(
          key: const ValueKey('home'),
          prayerTimes: prayerTimes,
          onRefresh: _handleRefresh,
        ),
      ),
    );
  }
}

// NOTE: The HomeContent widget remains unchanged as it is not affected by this logic.
class HomeContent extends StatelessWidget {
  final Map<String, String> prayerTimes;
  final Future<void> Function() onRefresh;

  const HomeContent({
    super.key,
    required this.prayerTimes,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefresh(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 50),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SafeArea(child: TopBar()),
            const SizedBox(height: 30),
            SalahTile(
              tileColor: const Color(0xffAF3E3E),
              salahLabel: 'fajr',
              fallbackTime: prayerTimes['fajr'] ?? '...',
            ),
            const SizedBox(height: 30),
            SalahTile(
              tileColor: const Color(0xff70B1E5),
              salahLabel: 'dhuhr',
              fallbackTime: prayerTimes['dhuhr'] ?? '...',
            ),
            const SizedBox(height: 30),
            SalahTile(
              tileColor: const Color(0xff629C5F),
              salahLabel: 'asr',
              fallbackTime: prayerTimes['asr'] ?? '...',
            ),
            const SizedBox(height: 30),
            SalahTile(
              tileColor: const Color(0xff5D5D5D),
              salahLabel: 'maghrib',
              fallbackTime: prayerTimes['maghrib'] ?? '...',
            ),
            const SizedBox(height: 30),
            SalahTile(
              tileColor: const Color(0xff8D7F7F),
              salahLabel: 'isha',
              fallbackTime: prayerTimes['isha'] ?? '...',
            ),
          ],
        ),
      ),
    );
  }
}