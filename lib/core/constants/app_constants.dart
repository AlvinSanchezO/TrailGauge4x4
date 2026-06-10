class AppConstants {
  // Frecuencia objetivo de sensores inerciales (~45Hz)
  static const int sensorUpdateIntervalMs = 22;

  // Límites por defecto de riesgo (Modo OEM Stock)
  static const double defaultMaxRoll = 30.0;
  static const double defaultMaxPitch = 35.0;

  // Ajuste para vehículos con kit de elevación (Reducción predictiva del 15%)
  static const double elevatedSuspensionFactor = 0.85;

  // Parámetro inicial (Alpha) para el Filtro de Paso Bajo (Ajustado a 0.08 para off-road severo)
  static const double defaultLowPassAlpha = 0.08; 

  // Endpoint de elevación barométrica corregida
  static const String openElevationApiUrl = 'https://api.open-elevation.com/api/v1/lookup';
}
