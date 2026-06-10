import 'geo_coordinates.dart';

abstract class TelemetryRepository {
  /// Devuelve el flujo constante de geolocalización fusionado con la API de altitud
  Stream<GeoCoordinates> getLocationStream();
}
