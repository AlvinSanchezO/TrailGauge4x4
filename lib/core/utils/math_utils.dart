class MathUtils {
  /// BR-01: Filtro de paso bajo matemático puro
  /// Fórmula: Y[n] = alpha * X[n] + (1 - alpha) * Y[n-1]
  static double applyLowPassFilter(double currentValue, double previousValue, double alpha) {
    return (alpha * currentValue) + ((1.0 - alpha) * previousValue);
  }

  /// BR-03: Calcula el umbral dinámico de alerta basado en la suspensión
  static double calculateDynamicThreshold(double baseLimit, bool isElevated) {
    return isElevated ? baseLimit * 0.85 : baseLimit;
  }

  /// BR-05: Convierte coordenadas decimales a formato DMS para radios VHF
  static String decimalToDMS(double coordinate, bool isLatitude) {
    String direction;
    if (isLatitude) {
      direction = coordinate >= 0 ? 'N' : 'S';
    } else {
      direction = coordinate >= 0 ? 'E' : 'W';
    }

    double absolute = coordinate.abs();
    int degrees = absolute.floor();
    double minutesDecimal = (absolute - degrees) * 60;
    int minutes = minutesDecimal.floor();
    int seconds = ((minutesDecimal - minutes) * 60).round();

    // Ajuste por redondeo a 60
    if (seconds == 60) {
      seconds = 0;
      minutes++;
    }
    if (minutes == 60) {
      minutes = 0;
      degrees++;
    }

    return "$degrees°$minutes'$seconds\" $direction";
  }
}
