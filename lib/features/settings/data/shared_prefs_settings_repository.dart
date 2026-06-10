import 'package:shared_preferences/shared_preferences.dart';
import '../domain/settings_repository.dart';
import '../../../core/constants/app_constants.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  // Claves de almacenamiento
  static const _keyPitchOffset = 'PITCH_OFFSET';
  static const _keyRollOffset = 'ROLL_OFFSET';
  static const _keyIsElevated = 'IS_ELEVATED';
  static const _keyMaxPitch = 'MAX_PITCH';
  static const _keyMaxRoll = 'MAX_ROLL';

  @override
  Future<void> saveCalibrationOffsets(double pitch, double roll) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyPitchOffset, pitch);
    await prefs.setDouble(_keyRollOffset, roll);
  }

  @override
  Future<Map<String, double>> getCalibrationOffsets() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'pitch': prefs.getDouble(_keyPitchOffset) ?? 0.0,
      'roll': prefs.getDouble(_keyRollOffset) ?? 0.0,
    };
  }

  @override
  Future<void> saveSuspensionMode(bool isElevated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsElevated, isElevated);
  }

  @override
  Future<bool> isSuspensionElevated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsElevated) ?? false;
  }

  @override
  Future<void> saveThresholds(double maxPitch, double maxRoll) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMaxPitch, maxPitch);
    await prefs.setDouble(_keyMaxRoll, maxRoll);
  }

  @override
  Future<Map<String, double>> getThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'pitch': prefs.getDouble(_keyMaxPitch) ?? AppConstants.defaultMaxPitch,
      'roll': prefs.getDouble(_keyMaxRoll) ?? AppConstants.defaultMaxRoll,
    };
  }
}
