import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:salah_shuttle/services/notification_service.dart';

// A top-level function is required for background execution
@pragma('vm:entry-point')
void fetchAndScheduleDaily() async {
  print("--- [Background Task] Starting daily prayer time fetch... ---");

  // Each isolate (background task) needs to initialize its own services.
  final notificationService = NotificationService();
  await notificationService.init();

  try {
    // --- Re-implement the fetching logic without any UI dependency ---
    if (!await Geolocator.isLocationServiceEnabled()) {
      print("[Background Task] Location services are disabled. Exiting.");
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(const Duration(seconds: 30));

    final coordinates = Coordinates(pos.latitude, pos.longitude);
    final params = CalculationMethod.karachi()..madhab = Madhab.hanafi;
    final date = DateTime.now();
    final times = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
    );

    // --- Re-implement the scheduling logic ---
    await _scheduleBackgroundNotifications(times, notificationService);
    print("--- [Background Task] Successfully scheduled notifications. ---");
  } catch (e) {
    print("--- [Background Task] Failed to run: $e ---");
  }
}

/// A background-safe version of the scheduling logic.
Future<void> _scheduleBackgroundNotifications(
    PrayerTimes times, NotificationService notificationService) async {
  await notificationService.cancelAllNotifications();

  final now = DateTime.now();
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
    final prayerTime = prayers[i].value;

    if (prayerTime == null || !prayerTime.isAfter(now)) {
      continue;
    }

    // Use 'intl' for formatting since we don't have a BuildContext
    final timeFormatter = DateFormat.jm();
    String nextPrayerInfo;
    final nextPrayerIndex = prayers.indexWhere(
        (p) => p.value != null && p.value!.isAfter(prayerTime), i + 1);

    if (nextPrayerIndex != -1) {
      final nextPrayer = prayers[nextPrayerIndex];
      final formattedTime = timeFormatter.format(nextPrayer.value!);
      nextPrayerInfo =
          'The next prayer is ${nextPrayer.key} at $formattedTime.';
    } else {
      nextPrayerInfo = 'Enjoy your evening. The next prayer is Fajr tomorrow.';
    }

    final notificationBody =
        'It\'s time for $prayerName prayer. $nextPrayerInfo';

    await notificationService.scheduleNotification(
      id: notificationId++,
      title: '$prayerName Prayer Reminder',
      body: notificationBody,
      scheduledTime: prayerTime,
    );
  }
}