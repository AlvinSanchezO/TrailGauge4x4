import 'package:flutter_test/flutter_test.dart';
import 'package:trail_gauge_4x4/core/utils/math_utils.dart';

void main() {
  group('MathUtils Tests - Base Matemática y Filtros', () {
    
    test('decimalToDMS convierte latitud positiva a Norte (BR-05)', () {
      final result = MathUtils.decimalToDMS(32.5149, true);
      // Math: 
      // 32.5149
      // degrees = 32
      // minDec = 0.5149 * 60 = 30.894
      // minutes = 30
      // seconds = 0.894 * 60 = 53.64 (redondeado a 54)
      expect(result, "32°30'54\" N");
    });

    test('decimalToDMS convierte longitud negativa a Oeste (BR-05)', () {
      final result = MathUtils.decimalToDMS(-117.0382, false);
      expect(result, "117°2'18\" W");
    });

    test('calculateDynamicThreshold reduce 15% en suspensión elevada (BR-03)', () {
      const stockLimit = 30.0;
      final elevatedLimit = MathUtils.calculateDynamicThreshold(stockLimit, true);
      expect(elevatedLimit, 25.5); // 30 * 0.85 = 25.5
    });

    test('calculateDynamicThreshold mantiene límite original en stock OEM (BR-03)', () {
      const stockLimit = 35.0;
      final stockResult = MathUtils.calculateDynamicThreshold(stockLimit, false);
      expect(stockResult, 35.0);
    });

    test('applyLowPassFilter suaviza el valor actual correctamente (BR-01)', () {
      const prev = 10.0;
      const current = 20.0;
      const alpha = 0.2;
      // Formula: Y[n] = alpha * X[n] + (1 - alpha) * Y[n-1]
      // 0.2 * 20.0 + 0.8 * 10.0 = 4.0 + 8.0 = 12.0
      final result = MathUtils.applyLowPassFilter(current, prev, alpha);
      expect(result, 12.0);
    });
  });
}
