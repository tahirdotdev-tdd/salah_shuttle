import 'package:adhan_dart/adhan_dart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:salah_shuttle/styles/fonts.dart';

class SalahTile extends StatefulWidget {
  final Color tileColor;
  final String salahLabel;
  final String fallbackTime;

  const SalahTile({
    super.key,
    required this.tileColor,
    required this.salahLabel,
    required this.fallbackTime,
  });

  @override
  State<SalahTile> createState() => _SalahTileState();
}

class _SalahTileState extends State<SalahTile> {
  bool _pressed = false;
  String salahTime = '...';
  String currentDate = DateFormat('EEEE, dd MMM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _determineTiming();
  }

  Future<void> _determineTiming() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity == ConnectivityResult.none;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception("Location service off");
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      final coordinates = Coordinates(pos.latitude, pos.longitude);
      final params = CalculationMethod.karachi()..madhab = Madhab.hanafi;

      final date = DateTime.now();
      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );

      DateTime? time;
      switch (widget.salahLabel.toLowerCase()) {
        case 'fajr':
          time = prayerTimes.fajr;
          break;
        case 'dhuhr':
          time = prayerTimes.dhuhr;
          break;
        case 'asr':
          time = prayerTimes.asr;
          break;
        case 'maghrib':
          time = prayerTimes.maghrib;
          break;
        case 'isha':
          time = prayerTimes.isha;
          break;
      }

      if (time != null) {
        final formatted = TimeOfDay.fromDateTime(
          time.toLocal(),
        ).format(context);
        setState(() => salahTime = formatted);
      } else {
        setState(() => salahTime = widget.fallbackTime);
      }
    } catch (e) {
      setState(() => salahTime = widget.fallbackTime);
    }
  }

  void _onTapDown(_) => setState(() => _pressed = true);
  void _onTapUp(_) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final tileWidth = width * 0.9;
    final tileHeight = tileWidth * 0.45;
    final shadowOffset = tileHeight * 0.065;
    final frontOffsetX = _pressed ? shadowOffset : 0;
    final frontOffsetY = _pressed ? shadowOffset : 0;

    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.5);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        height: tileHeight + shadowOffset,
        width: tileWidth,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              right: 0,
              top: shadowOffset,
              child: Container(
                height: tileHeight,
                width: tileWidth * 0.96,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF121212) : widget.tileColor,
                  border: Border.all(width: 3, color: borderColor),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),

            // Foreground
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(
                  frontOffsetX.toDouble(),
                  frontOffsetY.toDouble(),
                  0.0,
                ),
                child: Container(
                  height: tileHeight,
                  width: tileWidth * 0.965,
                  padding: EdgeInsets.all(tileHeight * 0.14),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF121212) : widget.tileColor,
                    border: Border.all(width: 3, color: borderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(currentDate, style: currentDateStyle(context)),
                        ],
                      ),
                      SizedBox(height: tileHeight * 0.06),

                      // Salah + Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.salahLabel, style: salahText(context)),
                          const Spacer(),
                          Text(salahTime, style: salahText(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
