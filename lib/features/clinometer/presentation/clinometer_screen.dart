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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.change_history, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRAILGAUGE 4X4', style: theme.appBarTheme.titleTextStyle),
                Text('[MODO: OFFLINE]', style: TextStyle(fontSize: 10, color: theme.colorScheme.tertiary, letterSpacing: 1.0)),
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
              stateColor = theme.colorScheme.primary;
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
                    Expanded(child: _buildDataCard(context, 'PITCH', attitude.pitch)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDataCard(context, 'ROLL', attitude.roll)),
                  ],
                ),
                
                const Spacer(),
                
                // Horizonte Artificial Circular
                Center(
                  child: _buildArtificialHorizon(context, attitude.roll, attitude.pitch, stateColor),
                ),

                const Spacer(),

                // Contenedor de Estado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stateColor, width: 2),
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
                Text('Filtro de paso bajo: 45Hz', style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 12)),
                Text('SYSTEM CALIBRATED: OK', style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 10, letterSpacing: 1.0)),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (error, stack) => Center(child: Text('Error: $error', style: TextStyle(color: AppTheme.dangerState))),
      ),
    );
  }

  Widget _buildDataCard(BuildContext context, String label, double value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.abs().toStringAsFixed(0),
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              Text(
                '° ',
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                value >= 0 ? (label == 'PITCH' ? 'UP' : 'R') : (label == 'PITCH' ? 'DOWN' : 'L'),
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtificialHorizon(BuildContext context, double roll, double pitch, Color stateColor) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Círculo base con cruz guía interna
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(width: 250, height: 1.5, color: theme.colorScheme.tertiary.withOpacity(0.5)),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(width: 1.5, height: 250, color: theme.colorScheme.tertiary.withOpacity(0.5)),
              ),
            ],
          ),
        ),
        
        // Etiqueta superior del círculo indicando el ángulo exacto combinado
        Positioned(
          top: -12, 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
            ),
            child: Text(
              '${roll.abs().toStringAsFixed(1)}°',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),

        // Silueta del Vehículo dibujada
        Center(
          child: Transform.rotate(
            angle: roll * pi / 180,
            alignment: Alignment.center,
            child: SizedBox(
              width: 140,
              height: 140,
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

class _CarSilhouettePainter extends CustomPainter {
  final Color color;

  _CarSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final double carHeight = size.width * 0.5;
    final double dy = (size.height - carHeight) / 2;

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

    canvas.drawCircle(Offset(size.width * 0.25, dy + carHeight * 0.8), carHeight * 0.2, paint);
    canvas.drawCircle(Offset(size.width * 0.75, dy + carHeight * 0.8), carHeight * 0.2, paint);
    canvas.drawCircle(Offset(size.width * 0.25, dy + carHeight * 0.8), carHeight * 0.05, paint);
    canvas.drawCircle(Offset(size.width * 0.75, dy + carHeight * 0.8), carHeight * 0.05, paint);

    canvas.drawLine(Offset(size.width * 0.45, size.height * 0.5), Offset(size.width * 0.55, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.45), Offset(size.width * 0.5, size.height * 0.55), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
