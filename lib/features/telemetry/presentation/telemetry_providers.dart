import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/telemetry_repository_impl.dart';
import '../domain/telemetry_repository.dart';
import '../domain/geo_coordinates.dart';

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  return TelemetryRepositoryImpl();
});

final locationStreamProvider = StreamProvider<GeoCoordinates>((ref) {
  final repo = ref.watch(telemetryRepositoryProvider);
  return repo.getLocationStream();
});
