abstract class SettingsRepository {
  // Matriz de Tara (Offsets 0°)
  Future<void> saveCalibrationOffsets(double pitch, double roll);
  Future<Map<String, double>> getCalibrationOffsets();

  // Configuración de Geometría (Elevada vs Stock)
  Future<void> saveSuspensionMode(bool isElevated);
  Future<bool> isSuspensionElevated();

  // Límites definidos en los Sliders
  Future<void> saveThresholds(double maxPitch, double maxRoll);
  Future<Map<String, double>> getThresholds();
}
