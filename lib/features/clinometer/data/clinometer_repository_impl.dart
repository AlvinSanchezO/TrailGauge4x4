import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../domain/clinometer_repository.dart';
import '../domain/vehicle_attitude.dart';
import '../../../core/errors/failures.dart';

class ClinometerRepositoryImpl implements ClinometerRepository {
  @override
  Stream<VehicleAttitude> getAttitudeStream() {
    // Escuchamos el acelerómetro para calcular inclinación absoluta
    return accelerometerEventStream().map((event) {
      // 1. ROLL (Inclinación Lateral):
      // Eje X mide el movimiento lateral.
      // Usamos Y y Z en la raíz cuadrada para anclar el denominador como magnitud positiva constante.
      double rollDenominator = sqrt((event.y * event.y) + (event.z * event.z));
      double rollRad = atan2(event.x, rollDenominator);

      // 2. PITCH (Cabeceo Frontal):
      // Eje Z mide el movimiento frontal/trasero.
      // Usamos X y Y en la raíz cuadrada para anclar el denominador.
      double pitchDenominator = sqrt((event.x * event.x) + (event.y * event.y));
      double pitchRad = atan2(event.z, pitchDenominator);

      // 3. Conversión a Grados Puros (-90° a +90°)
      double rawRoll = rollRad * (180 / pi);
      double rawPitch = pitchRad * (180 / pi);
      return VehicleAttitude(pitch: rawPitch, roll: rawRoll);
    }).handleError((error) {
      throw SensorFailure();
    });
  }
}
