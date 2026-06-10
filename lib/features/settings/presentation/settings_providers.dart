import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/shared_prefs_settings_repository.dart';
import '../domain/settings_repository.dart';

// Inyecta el repositorio de almacenamiento
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SharedPrefsSettingsRepository();
});

// Provee la matriz de tara (Offsets 0°) de forma asíncrona
final calibrationOffsetsProvider = FutureProvider<Map<String, double>>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getCalibrationOffsets();
});

// Provee si la suspensión está elevada
final suspensionModeProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.isSuspensionElevated();
});

// Provee los límites de riesgo
final thresholdsProvider = FutureProvider<Map<String, double>>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getThresholds();
});
