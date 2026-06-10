import '../../../core/utils/math_utils.dart';

class GeoCoordinates {
  final double latitude;
  final double longitude;
  final double altitudeMeters;
  final bool isAltitudeFromApi;
  final double speedKmh;

  GeoCoordinates({
    required this.latitude,
    required this.longitude,
    required this.altitudeMeters,
    required this.isAltitudeFromApi,
    this.speedKmh = 0.0,
  });

  // Retorna formato decimal: "Lat 32.5149° N / Lon 117.0382° W"
  String get decimalFormat {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lonDir = longitude >= 0 ? 'E' : 'W';
    return "Lat ${latitude.abs().toStringAsFixed(4)}° $latDir / Lon ${longitude.abs().toStringAsFixed(4)}° $lonDir";
  }

  // Retorna formato DMS usando MathUtils
  String get dmsFormat {
    final latDms = MathUtils.decimalToDMS(latitude, true);
    final lonDms = MathUtils.decimalToDMS(longitude, false);
    return "$latDms / $lonDms";
  }
}
