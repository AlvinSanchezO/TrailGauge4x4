import '../../../core/constants/app_constants.dart';
import '../../../core/utils/math_utils.dart';

enum SafetyState { safe, warning, danger }

class VehicleAttitude {
  final double pitch;
  final double roll;

  VehicleAttitude({required this.pitch, required this.roll});

  /// BR-03: Evaluación en tiempo real del riesgo
  SafetyState getSafetyState(double maxPitch, double maxRoll, bool isElevated) {
    final limitPitch = MathUtils.calculateDynamicThreshold(maxPitch, isElevated);
    final limitRoll = MathUtils.calculateDynamicThreshold(maxRoll, isElevated);

    // Advertencia al 80% del límite
    final warningPitch = limitPitch * 0.8;
    final warningRoll = limitRoll * 0.8;

    if (pitch.abs() >= limitPitch || roll.abs() >= limitRoll) {
      return SafetyState.danger;
    } else if (pitch.abs() >= warningPitch || roll.abs() >= warningRoll) {
      return SafetyState.warning;
    }
    return SafetyState.safe;
  }
}
