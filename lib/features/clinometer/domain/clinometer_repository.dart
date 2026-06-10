import 'vehicle_attitude.dart';

/// Contrato estricto para la capa de datos
abstract class ClinometerRepository {
  /// Devuelve el flujo crudo a ~45Hz (la calibración se hace en Riverpod).
  Stream<VehicleAttitude> getAttitudeStream();
}
