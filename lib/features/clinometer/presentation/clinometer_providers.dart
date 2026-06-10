import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/clinometer_repository_impl.dart';
import '../domain/clinometer_repository.dart';
import '../domain/vehicle_attitude.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/math_utils.dart';

// Inyecta el acceso directo a los sensores
final clinometerRepositoryProvider = Provider<ClinometerRepository>((ref) {
  return ClinometerRepositoryImpl();
});

class VehicleAttitudeNotifier extends StreamNotifier<VehicleAttitude> {
  // Estado histórico aislado y protegido del redibujado de la UI
  double _lastPitch = 0.0;
  double _lastRoll = 0.0;

  @override
  Stream<VehicleAttitude> build() async* {
    final repository = ref.watch(clinometerRepositoryProvider);
    final offsets = await ref.watch(calibrationOffsetsProvider.future);
    
    final pitchOffset = offsets['pitch'] ?? 0.0;
    final rollOffset = offsets['roll'] ?? 0.0;

    await for (final rawAttitude in repository.getAttitudeStream()) {
      _lastPitch = MathUtils.applyLowPassFilter(rawAttitude.pitch, _lastPitch, AppConstants.defaultLowPassAlpha);
      _lastRoll = MathUtils.applyLowPassFilter(rawAttitude.roll, _lastRoll, AppConstants.defaultLowPassAlpha);

      yield VehicleAttitude(
        pitch: _lastPitch - pitchOffset,
        roll: _lastRoll - rollOffset,
      );
    }
  }
}

// EL CORAZÓN DEL SISTEMA: Stream que fusiona Sensores + Configuración (Tara)
final vehicleAttitudeStreamProvider = StreamNotifierProvider<VehicleAttitudeNotifier, VehicleAttitude>(() {
  return VehicleAttitudeNotifier();
});
