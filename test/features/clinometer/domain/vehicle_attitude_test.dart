import 'package:flutter_test/flutter_test.dart';
import 'package:trail_gauge_4x4/features/clinometer/domain/vehicle_attitude.dart';

void main() {
  group('VehicleAttitude Safety State (BR-03)', () {
    
    test('Retorna SAFE si la inclinación está muy por debajo de los límites', () {
      final attitude = VehicleAttitude(pitch: 10.0, roll: 5.0);
      expect(attitude.getSafetyState(35.0, 30.0, false), SafetyState.safe);
    });

    test('Retorna WARNING al superar el 80% del límite en Pitch', () {
      // 80% de 35 es 28. Un pitch de 29 debe ser Warning.
      final attitude = VehicleAttitude(pitch: 29.0, roll: 0.0); 
      expect(attitude.getSafetyState(35.0, 30.0, false), SafetyState.warning);
    });

    test('Retorna WARNING al superar el 80% del límite en Roll', () {
      // 80% de 30 es 24. Un roll de 25 debe ser Warning.
      final attitude = VehicleAttitude(pitch: 0.0, roll: 25.0); 
      expect(attitude.getSafetyState(35.0, 30.0, false), SafetyState.warning);
    });

    test('Retorna DANGER al cruzar o igualar el límite estricto OEM', () {
      final attitude = VehicleAttitude(pitch: 36.0, roll: 0.0);
      expect(attitude.getSafetyState(35.0, 30.0, false), SafetyState.danger);
    });

    test('Retorna DANGER prematuro si la suspensión está elevada (-15%)', () {
      // Si está elevada, el límite de Roll baja de 30.0 a 25.5
      // Un roll de 26 sería SAFE/WARNING en Stock, pero DANGER en Elevada
      final attitude = VehicleAttitude(pitch: 0.0, roll: 26.0);
      
      // Stock Mode (false) -> Debería ser Warning porque supera 24 (80% de 30)
      expect(attitude.getSafetyState(35.0, 30.0, false), SafetyState.warning);
      
      // Elevated Mode (true) -> Debería ser Danger porque supera 25.5 (nuevo límite 100%)
      expect(attitude.getSafetyState(35.0, 30.0, true), SafetyState.danger);
    });

  });
}
