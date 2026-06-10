import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vehicle_attitude.dart';
import '../presentation/clinometer_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../../core/theme/app_theme.dart';

class ClinometerScreen extends ConsumerWidget {
  const ClinometerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attitudeAsyncValue = ref.watch(vehicleAttitudeStreamProvider);
    final thresholds = ref.watch(thresholdsProvider).value;
    final isElevated = ref.watch(suspensionModeProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.change_history, size: 24, color: AppTheme.primaryNavy), // Logo genérico
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('TRAILGAUGE 4X4', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text('[MODO: OFFLINE]', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.0)),
              ],
            ),
          ],
        ),
      ),
      body: attitudeAsyncValue.when(
        data: (attitude) {
          final maxPitch = thresholds?['pitch'] ?? 35.0;
          final maxRoll = thresholds?['roll'] ?? 30.0;
          final safetyState = attitude.getSafetyState(maxPitch, maxRoll, isElevated);

          Color stateColor;
          String stateText;
          switch (safetyState) {
            case SafetyState.danger:
              stateColor = AppTheme.dangerState;
              stateText = '[ESTADO: PELIGRO CRÍTICO]';
              break;
            case SafetyState.warning:
              stateColor = AppTheme.warningState;
              stateText = '[ESTADO: ADVERTENCIA]';
              break;
            case SafetyState.safe:
            default:
              stateColor = AppTheme.safeState; // Azul Marino
              stateText = '[ESTADO: SEGURO]';
              break;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: [
                // Tarjetas Rectangulares Superiores
                Row(
                  children: [
                    Expanded(child: _buildDataCard('PITCH', attitude.pitch)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDataCard('ROLL', attitude.roll)),
                  ],
                ),
                
                const Spacer(),
                
                // Horizonte Artificial Circular (Wireframe exacto)
                Center(
                  child: _buildArtificialHorizon(attitude.roll, attitude.pitch, stateColor),
                ),

                const Spacer(),

                // Contenedor de Estado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: stateColor, width: 2), // Borde grueso del color de estado
                  ),
                  child: Text(
                    stateText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: stateColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Footer Técnico
                const Text('Filtro de paso bajo: 45Hz', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Text('SYSTEM CALIBRATED: OK', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.0)),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy)),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // Tarjeta Blanca con Borde Gris
  Widget _buildDataCard(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderGray, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.abs().toStringAsFixed(0),
                style: const TextStyle(color: AppTheme.primaryNavy, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const Text(
                '° ',
                style: TextStyle(color: AppTheme.primaryNavy, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                value >= 0 ? (label == 'PITCH' ? 'UP' : 'R') : (label == 'PITCH' ? 'DOWN' : 'L'),
                style: const TextStyle(color: AppTheme.primaryNavy, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Contenedor Circular con la Silueta
  Widget _buildArtificialHorizon(double roll, double pitch, Color stateColor) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, // Permite que el cuadrito de 18.0° sobresalga
      children: [
        // Círculo base con cruz guía interna
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.borderGray, width: 1.5),
          ),
          child: Stack(
            children: [
              // Línea Horizontal
              Align(
                alignment: Alignment.center,
                child: Container(width: 250, height: 1.5, color: AppTheme.borderGray.withOpacity(0.5)),
              ),
              // Línea Vertical
              Align(
                alignment: Alignment.center,
                child: Container(width: 1.5, height: 250, color: AppTheme.borderGray.withOpacity(0.5)),
              ),
            ],
          ),
        ),
        
        // Etiqueta superior del círculo indicando el ángulo exacto combinado (Wireframe)
        Positioned(
          top: -12, 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.borderGray, width: 1.5),
            ),
            child: Text(
              '${roll.abs().toStringAsFixed(1)}°',
              style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),

        // Silueta del Vehículo dibujada        // CORRECCIÓN BUG UX: Silueta central fija, reacciona sólo al Roll.
        Center(
          child: Transform.rotate(
            angle: roll * pi / 180, // Rotación Lateral (Roll)
            alignment: Alignment.center, // Fuerza a rotar sobre su centro exacto
            child: SizedBox(
              width: 140,
              height: 140, // Contenedor estrictamente cuadrado
              child: CustomPaint(
                painter: _CarSilhouettePainter(color: stateColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Pintor Vectorial para la silueta del vehículo off-road (Wireframe 1 exacto)
class _CarSilhouettePainter extends CustomPainter {
  final Color color;

  _CarSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Para evitar que el carro se deforme al hacerlo cuadrado, calculamos la geometría relativa
    final double carHeight = size.width * 0.5; // Relación 2:1 ancho/alto
    final double dy = (size.height - carHeight) / 2; // Offset vertical para centrarlo exactamente

    // Cuerpo cuadrado del vehículo SUV
    final path = Path();
    path.moveTo(0, dy + carHeight * 0.45);
    path.lineTo(size.width * 0.25, dy + carHeight * 0.45); 
    path.lineTo(size.width * 0.40, dy + carHeight * 0.1); 
    path.lineTo(size.width * 0.75, dy + carHeight * 0.1); 
    path.lineTo(size.width * 0.85, dy + carHeight * 0.45); 
    path.lineTo(size.width, dy + carHeight * 0.45); 
    path.lineTo(size.width, dy + carHeight * 0.8); 
    path.lineTo(0, dy + carHeight * 0.8);
    path.close();
    canvas.drawPath(path, paint);

    // Ruedas y rines
    canvas.drawCircle(Offset(size.width * 0.25, dy + carHeight * 0.8), carHeight * 0.2, paint);
    canvas.drawCircle(Offset(size.width * 0.75, dy + carHeight * 0.8), carHeight * 0.2, paint);
    canvas.drawCircle(Offset(size.width * 0.25, dy + carHeight * 0.8), carHeight * 0.05, paint);
    canvas.drawCircle(Offset(size.width * 0.75, dy + carHeight * 0.8), carHeight * 0.05, paint);

    // Cruz central interna de la silueta (matemáticamente centrada en el cuadrado 140x140)
    canvas.drawLine(Offset(size.width * 0.45, size.height * 0.5), Offset(size.width * 0.55, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.45), Offset(size.width * 0.5, size.height * 0.55), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
