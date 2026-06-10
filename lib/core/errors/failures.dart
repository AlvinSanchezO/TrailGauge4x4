abstract class Failure {
  final String message;
  Failure(this.message);
}

class SensorFailure extends Failure {
  SensorFailure([String message = "Sensor inercial no disponible o dañado"]) : super(message);
}

class GpsFailure extends Failure {
  GpsFailure([String message = "Sin señal satelital GPS"]) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = "Error de conexión con API topográfica"]) : super(message);
}
