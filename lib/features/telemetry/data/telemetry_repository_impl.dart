import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../domain/telemetry_repository.dart';
import '../domain/geo_coordinates.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';

class TelemetryRepositoryImpl implements TelemetryRepository {
  @override
  Stream<GeoCoordinates> getLocationStream() async* {
    // 1. Pedir permisos de ubicación si es necesario
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw GpsFailure('Servicios de ubicación deshabilitados en el dispositivo.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw GpsFailure('Permisos de GPS denegados por el usuario.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw GpsFailure('Permisos de GPS denegados permanentemente.');
    }

    // 2. Configurar el Stream con un filtro de distancia menor para una UI fluida
    // CRÍTICO: Mantendremos el límite de 10 metros LÓGICAMENTE para no saturar la API de Open-Elevation.
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Actualizaciones cada metro de movimiento
    );

    Position? lastApiPosition;
    double lastApiAltitude = 0.0;
    bool lastWasFromApi = false;

    // 3. Suscribirse y mapear asincrónicamente cada posición (asyncMap)
    yield* Geolocator.getPositionStream(locationSettings: locationSettings).asyncMap((position) async {
      double altitude = position.altitude;
      bool fromApi = false;

      bool shouldCallApi = false;
      if (lastApiPosition == null) {
        shouldCallApi = true;
      } else {
        final distance = Geolocator.distanceBetween(
          lastApiPosition!.latitude, lastApiPosition!.longitude,
          position.latitude, position.longitude
        );
        if (distance >= 10.0) {
          shouldCallApi = true;
        }
      }

      if (shouldCallApi) {
        // 4. Cruzar coordenadas con Open-Elevation API (BR-05)
        try {
          final url = Uri.parse('${AppConstants.openElevationApiUrl}?locations=${position.latitude},${position.longitude}');
          // Timeout corto: En off-road, la red 3G/4G puede ser intermitente
          final response = await http.get(url).timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['results'] != null && data['results'].isNotEmpty) {
              // Reemplazar la altitud de presión barométrica (imprecisa) por la topográfica satelital
              altitude = (data['results'][0]['elevation'] as num).toDouble();
              fromApi = true;

              lastApiPosition = position;
              lastApiAltitude = altitude;
              lastWasFromApi = true;
            }
          }
        } catch (e) {
          // Fallback Silencioso: Si falla la red en el campo, usamos el altímetro del GPS de forma transparente
          fromApi = false;
        }
      } else {
        // Si no nos hemos movido 10 metros, reusamos el último valor de la API si fue exitoso
        if (lastWasFromApi) {
          altitude = lastApiAltitude;
          fromApi = true;
        } else {
          altitude = position.altitude;
          fromApi = false;
        }
      }

      return GeoCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        altitudeMeters: altitude,
        isAltitudeFromApi: fromApi,
        speedKmh: position.speed * 3.6, // m/s to km/h
      );
    });
  }
}
