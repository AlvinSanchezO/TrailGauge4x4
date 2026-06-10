import 'dart:math';

void main() {
  List<Map<String, double>> tests = [
    {'x': 0.0, 'y': 9.8, 'z': 0.0}, // Upright
    {'x': 9.8, 'y': 0.0, 'z': 0.0}, // Right side
    {'x': 0.0, 'y': 0.0, 'z': 9.8}, // Flat facing up
    {'x': 0.1, 'y': 0.1, 'z': 9.8}, // Flat facing up + noise
    {'x': -0.1, 'y': -0.1, 'z': 9.8}, // Flat facing up + noise
    {'x': 0.5, 'y': -0.2, 'z': 9.7}, // Tilted up slightly
  ];

  for (var test in tests) {
    double x = test['x']!;
    double y = test['y']!;
    double z = test['z']!;
    
    double rollDenominator = sqrt((y * y) + (z * z));
    double rollRad = atan2(x, rollDenominator);
    double rollDeg = rollRad * (180 / pi);
    
    double pitchDenominator = sqrt((x * x) + (y * y));
    double pitchRad = atan2(z, pitchDenominator);
    double pitchDeg = pitchRad * (180 / pi);
    
    print('X:$x Y:$y Z:$z -> Roll: ${rollDeg.toStringAsFixed(2)}, Pitch: ${pitchDeg.toStringAsFixed(2)}');
  }
}
