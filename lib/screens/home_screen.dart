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
  Map<String, String> prayerTimes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception("Location disabled");
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      final coordinates = Coordinates(pos.latitude, pos.longitude);
      final params = CalculationMethod.karachi();
      params.madhab = Madhab.hanafi;

      DateTime date = DateTime.now();
      final times = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params);

      setState(() {
        prayerTimes = {
          'fajr': times.fajr != null ? _formatTime(times.fajr!) : 'N/A',
          'dhuhr': times.dhuhr != null ? _formatTime(times.dhuhr!) : 'N/A',
          'asr': times.asr != null ? _formatTime(times.asr!) : 'N/A',
          'maghrib': times.maghrib != null ? _formatTime(times.maghrib!) : 'N/A',
          'isha': times.isha != null ? _formatTime(times.isha!) : 'N/A',
        };
        isLoading = false;
      });
    } catch (e) {
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
