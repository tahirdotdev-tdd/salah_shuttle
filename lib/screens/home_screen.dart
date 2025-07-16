import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:salah_shuttle/services/notification_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          titlePadding: const EdgeInsets.only(top: 16, left: 20, right: 8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'No Internet Connection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 25, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: const Text(
            textAlign: TextAlign.center,
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
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.contains(ConnectivityResult.none) && !isLoading) {
        _showOfflineSnackbar();
      }
    });
  }

  /// ✅ CORRECTED AND NULL-SAFE
  /// Fetches location, calculates prayer times, updates UI, and schedules notifications.
  Future<void> _fetchPrayerTimes() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity()
        .checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception("Location services are disabled.");
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      final coordinates = Coordinates(pos.latitude, pos.longitude);
      final params = CalculationMethod.karachi()..madhab = Madhab.hanafi;
      final date = DateTime.now();
      final times = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );

      if (!mounted) return;

      // Schedule notifications using the new 'times' object
      await _scheduleNotifications(times);

      // Update the UI with formatted times, safely handling nulls
      setState(() {
        prayerTimes = {
          'fajr': times.fajr == null ? '--:--' : _formatTime(times.fajr!),
          'dhuhr': times.dhuhr == null ? '--:--' : _formatTime(times.dhuhr!),
          'asr': times.asr == null ? '--:--' : _formatTime(times.asr!),
          'maghrib': times.maghrib == null
              ? '--:--'
              : _formatTime(times.maghrib!),
          'isha': times.isha == null ? '--:--' : _formatTime(times.isha!),
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

  /// ✅ CORRECTED AND NULL-SAFE
  /// A helper method to handle scheduling of all prayer notifications.
  Future<void> _scheduleNotifications(PrayerTimes times) async {
    final notificationService = NotificationService();
    await notificationService.cancelAllNotifications();

    final now = DateTime.now();

    // The list must accept nullable DateTimes from the 'times' object
    final List<MapEntry<String, DateTime?>> prayers = [
      MapEntry('Fajr', times.fajr),
      MapEntry('Dhuhr', times.dhuhr),
      MapEntry('Asr', times.asr),
      MapEntry('Maghrib', times.maghrib),
      MapEntry('Isha', times.isha),
    ];

    int notificationId = 0;

    for (int i = 0; i < prayers.length; i++) {
      final prayerName = prayers[i].key;
      final prayerTime = prayers[i].value; // This is a DateTime?

      // Skip this prayer if its time is null or has already passed
      if (prayerTime == null || !prayerTime.isAfter(now)) {
        continue;
      }

      // --- Logic to find the next valid prayer for the notification body ---
      String nextPrayerInfo;
      // Find the index of the next prayer that is not null
      final nextPrayerIndex = prayers.indexWhere(
        (p) => p.value != null && p.value!.isAfter(prayerTime),
        i + 1,
      );

      if (nextPrayerIndex != -1) {
        // If a valid next prayer is found
        final nextPrayer = prayers[nextPrayerIndex];
        // We can use '!' because indexWhere confirmed value is not null
        final formattedTime = _formatTime(nextPrayer.value!);
        nextPrayerInfo =
            'The next prayer is ${nextPrayer.key} at $formattedTime.';
      } else {
        // If no next prayer is found for today (i.e., we are scheduling Isha)
        nextPrayerInfo =
            'Enjoy your evening. The next prayer is Fajr tomorrow.';
      }

      final notificationBody =
          'It\'s time for $prayerName prayer. $nextPrayerInfo';

      // Schedule the notification. 'prayerTime' is guaranteed to be non-null here.
      await notificationService.scheduleNotification(
        id: notificationId++,
        title: '$prayerName Prayer Reminder',
        body: notificationBody,
        scheduledTime: prayerTime,
      );
    }
  }

  /// Formats a non-nullable DateTime into a string.
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
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xfff3e8cb),
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

// NOTE: The HomeContent widget remains unchanged.
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
