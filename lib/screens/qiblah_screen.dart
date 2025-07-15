import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:salah_shuttle/styles/colors.dart';
import 'package:salah_shuttle/styles/fonts.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  double? qiblahDirection;
  double? heading;
  String? _error;
  StreamSubscription<CompassEvent>? _compassSubscription;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Subscribe to connectivity changes
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    // Initial attempt to get Qiblah direction
    _initializeQiblah();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    // Cancel the connectivity subscription to prevent memory leaks
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// Listens to connectivity changes and retries initialization if connection is restored.
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    // If we now have a connection and there was a previous error, try again.
    if (!result.contains(ConnectivityResult.none) && _error != null) {
      _initializeQiblah();
    }
  }

  /// Initializes the Qiblah logic: checks permissions, gets location, and fetches direction.
  Future<void> _initializeQiblah() async {
    setState(() {
      _error = null;
      qiblahDirection = null;
      heading = null;
    });

    // 1. Check for internet connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        setState(() {
          _error = "Please turn on your internet connection to find the Qiblah direction.";
        });
      }
      return; // Stop if no internet
    }

    try {
      // 2. Check for location services and permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Please enable location services.");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Location permission denied.");
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied. Please enable it from app settings.");
      }

      // 3. Get current position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // 4. Fetch Qiblah direction from API
      final url = Uri.parse('https://api.aladhan.com/v1/qibla/${position.latitude}/${position.longitude}');
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw Exception("Failed to fetch Qiblah direction from the server.");

      final data = jsonDecode(response.body);

      // 5. Start listening to compass events
      _compassSubscription?.cancel(); // Ensure any old subscription is cancelled
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (mounted && event.heading != null) {
          setState(() {
            heading = event.heading;
          });
        }
      });

      // 6. Update the state with the fetched Qiblah direction
      if (mounted) {
        setState(() {
          qiblahDirection = (data['data']['direction'] as num).toDouble();
        });
      }
    } on SocketException {
      // Catch specific network errors during the HTTP request
      if (mounted) {
        setState(() => _error = "No internet connection. Please check your network and try again.");
      }
    } on TimeoutException {
      // Catch errors if the request takes too long
       if (mounted) {
        setState(() => _error = "The request timed out. Please try again.");
      }
    } catch (e) {
      // Catch all other errors (permissions, etc.)
      if (mounted) {
        // Clean up the exception message for better display
        setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
      }
    }
  }

  static const double alignmentThreshold = 5.0;

  bool get isAligned {
    if (heading == null || qiblahDirection == null) return false;
    double diff = (heading! - qiblahDirection!).abs();
    if (diff > 180) diff = 360 - diff;
    return diff <= alignmentThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_outlined,
              color: isDark ? Colors.white : Colors.black),
        ),
        title: Text("Qiblah Compass", style: standardFont(context)),
        backgroundColor: isDark ? const Color(0xFF121212) : scaffoldBackgroundColor,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Center(child: _buildMainContent(isDark)),
    );
  }

  Widget _buildMainContent(bool isDark) {
    // If there is an error, display it.
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 60),
            const SizedBox(height: 20),
            Text(
              _error!,
              style: TextStyle(color: isDark ? Colors.red[200] : Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _initializeQiblah,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.teal.shade700 : Colors.brown.shade700,
              ),
            ),
          ],
        ),
      );
    }

    // While waiting for the qiblah direction, show a loading indicator.
    if (qiblahDirection == null) {
      return LoadingAnimationWidget.staggeredDotsWave(
        color: isDark ? Colors.teal : Colors.green,
        size: 100,
      );
    }
    
    // Once data is available, show the compass.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text("Qiblah Direction", style: standardFont(context)),
        const SizedBox(height: 16),
        _buildCompassCard(isDark),
        const SizedBox(height: 24),
        _buildDirectionDetails(isDark),
      ],
    );
  }

   // The rest of your UI-building methods (_buildCompassCard, _buildDirectionDetails, etc.) remain unchanged.
  // ... (Paste your existing _buildCompassCard, _buildDirectionDetails, _buildValueRow, _QiblahDot, and _CompassRosePainter here)
  // ...


  Widget _buildCompassCard(bool isDark) {
    final double compassRotation = -(heading ?? 0) * math.pi / 180;
    final double qiblahAngle = ((qiblahDirection ?? 0) - (heading ?? 0)) * math.pi / 180;

    return Container(
      width: 310,
      height: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(180),
        gradient: isDark
            ? const LinearGradient(
          colors: [Color(0xFF374151), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFFfceabb), Color(0xFFf8b500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.brown.withOpacity(0.12),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: compassRotation,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[900] : Colors.white.withOpacity(0.94),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.brown.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: CustomPaint(
                painter: _CompassRosePainter(isDark: isDark),
              ),
            ),
          ),
          _QiblahDot(
            angle: qiblahAngle,
            isAligned: isAligned,
            radius: 108,
          ),
          const Positioned(
            top: 18,
            child: Text(
              "N",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildValueRow("Qiblah", qiblahDirection?.toStringAsFixed(1), "° from North", Icons.explore, isDark),
        const SizedBox(height: 8),
        _buildValueRow("Your Heading", heading?.toStringAsFixed(1) ?? '...', "° from North", Icons.compass_calibration, isDark),
        const SizedBox(height: 18),
        Text(
          "Align your phone so that the bright dot is at the top of the circle. The dot will turn red when perfectly aligned.",
          textAlign: TextAlign.center,
          style: qiblahText(context),
        ),
      ],
    );
  }

  Widget _buildValueRow(String label, String? value, String unit, IconData icon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isDark ? Colors.tealAccent : Colors.brown.shade700, size: 22),
        const SizedBox(width: 8),
        Text("$label: ", style: qiblahText(context)),
        Text(value ?? "-", style: qiblahText(context)),
        Text(unit, style: qiblahText(context)),
      ],
    );
  }
}

class _QiblahDot extends StatelessWidget {
  final double angle;
  final bool isAligned;
  final double radius;

  const _QiblahDot({
    required this.angle,
    required this.isAligned,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final double dx = radius * math.sin(angle);
    final double dy = -radius * math.cos(angle);
    return Positioned(
      left: 155 + dx - 12,
      top: 155 + dy - 12,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isAligned ? Colors.red : Colors.yellowAccent.shade700,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isAligned ? Colors.red.withOpacity(0.6) : Colors.yellowAccent.withOpacity(0.6),
              blurRadius: 24,
              spreadRadius: 8,
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  final bool isDark;

  _CompassRosePainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.grey[700]! : Colors.brown.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    canvas.drawCircle(center, radius, paint);

    for (int i = 0; i < 360; i += 30) {
      final angle = (i - 90) * math.pi / 180.0;
      final x1 = center.dx + radius * math.cos(angle);
      final y1 = center.dy + radius * math.sin(angle);
      final x2 = center.dx + (radius - 14) * math.cos(angle);
      final y2 = center.dy + (radius - 14) * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
