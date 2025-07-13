import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

Future<PrayerTimes> getPrayerTimes(Position pos) async {
  final coordinates = Coordinates(pos.latitude, pos.longitude);

  final params = CalculationMethod.karachi().getParameters();
  params.madhab = Madhab.hanafi;

  final date = DateTime.now();

  return PrayerTimes(
    coordinates: coordinates,
    date: date,
    calculationParameters: params,
  );
}
