import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'telemetry_providers.dart';
import '../../../core/theme/app_theme.dart';

class TelemetryScreen extends ConsumerWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.change_history, size: 24, color: AppTheme.primaryNavy),
            const SizedBox(width: 8),
            const Text('TRAILGAUGE 4X4', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.satellite_alt, color: AppTheme.primaryNavy, size: 20),
          )
        ],
      ),
      body: locationAsync.when(
        data: (coords) => SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('TELEMETRÍA Y\nCOORDENADAS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryNavy, height: 1.2)),
              const SizedBox(height: 4),
              const Text('Sincronización en tiempo real vía satélite', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 24),

              // Tarjeta Velocidad (Como pide el Wireframe, se deja placeholder fijo por ahora)
              _buildLightCard(
                context,
                title: 'VELOCIDAD ACTUAL',
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(coords.speedKmh.toStringAsFixed(0), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryNavy)),
                    const SizedBox(width: 4),
                    const Text('km/h', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    const Spacer(),
                    const Icon(Icons.speed, color: AppTheme.primaryNavy),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tarjeta Altitud
              _buildLightCard(
                context,
                title: coords.isAltitudeFromApi ? 'ALTITUD (API)' : 'ALTITUD (GPS NATIVO)',
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(coords.altitudeMeters.toStringAsFixed(0), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryNavy)),
                    const SizedBox(width: 4),
                    const Text('msnm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    const Spacer(),
                    const Icon(Icons.terrain, color: AppTheme.primaryNavy),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tarjeta Coordenadas Decimales
              _buildLightCard(
                context,
                title: 'COORDENADAS DECIMALES',
                content: Text(coords.decimalFormat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy, height: 1.5)),
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),

              // Tarjeta Dark Mode (Transmisión de Rescate DMS)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: AppTheme.primaryNavy), // Sin bordes redondeados según Wireframe
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.security, color: Colors.grey, size: 16),
                        SizedBox(width: 8),
                        Text('TRANSMISIÓN DE RESCATE (DMS)', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(coords.dmsFormat, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PROTOCOLO ACTIVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.dangerState, shape: BoxShape.circle)),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Gráfico Perfil de Elevación Placeholder (Wireframe Box con Cruz)
              const Text('[GRÁFICO - PERFIL DE ELEVACIÓN DE RUTA]', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  border: Border.all(color: AppTheme.primaryNavy, width: 1),
                ),
                child: Stack(
                  children: [
                    CustomPaint(size: const Size(double.infinity, 150), painter: _CrossPainter()),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('ELEVATION DATA STREAM', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, fontSize: 12)),
                            Text('Real-time topographic mapping', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy)),
        error: (err, stack) => Center(child: Text('Error GPS:\n$err', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.dangerState))),
      ),
    );
  }

  Widget _buildLightCard(BuildContext context, {required String title, required Widget content, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.borderGray, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: Colors.grey, size: 16), const SizedBox(width: 8)],
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
