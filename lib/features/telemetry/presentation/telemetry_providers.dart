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

class ElevationHistoryNotifier extends Notifier<List<double>> {
  @override
  List<double> build() {
    ref.listen<AsyncValue<GeoCoordinates>>(locationStreamProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        _addElevation(next.value!.altitudeMeters);
      }
    });
    return [];
  }

  void _addElevation(double altitude) {
    final newList = List<double>.from(state);
    newList.add(altitude);
    if (newList.length > 25) {
      newList.removeAt(0);
    }
    state = newList;
  }
}

final elevationHistoryProvider = NotifierProvider<ElevationHistoryNotifier, List<double>>(() {
  return ElevationHistoryNotifier();
});
