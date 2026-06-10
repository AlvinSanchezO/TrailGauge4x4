import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'telemetry_providers.dart';
import '../../../core/theme/app_theme.dart';

class TelemetryScreen extends ConsumerWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationStreamProvider);
    final elevationHistory = ref.watch(elevationHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.change_history, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('TRAILGAUGE 4X4', style: theme.appBarTheme.titleTextStyle),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.satellite_alt, color: theme.colorScheme.primary, size: 20),
          )
        ],
      ),
      body: locationAsync.when(
        data: (coords) => SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('TELEMETRÍA Y\nCOORDENADAS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, height: 1.2)),
              const SizedBox(height: 4),
              Text('Sincronización en tiempo real vía satélite', style: TextStyle(fontSize: 12, color: theme.colorScheme.tertiary)),
              const SizedBox(height: 24),

              // Tarjeta Velocidad
              _buildLightCard(
                context,
                title: 'VELOCIDAD ACTUAL',
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(coords.speedKmh.toStringAsFixed(0), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                    const SizedBox(width: 4),
                    Text('km/h', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                    const Spacer(),
                    Icon(Icons.speed, color: theme.colorScheme.primary),
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
                    Text(coords.altitudeMeters.toStringAsFixed(0), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                    const SizedBox(width: 4),
                    Text('msnm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                    const Spacer(),
                    Icon(Icons.terrain, color: theme.colorScheme.primary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tarjeta Coordenadas Decimales
              _buildLightCard(
                context,
                title: 'COORDENADAS DECIMALES',
                content: Text(coords.decimalFormat, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary, height: 1.5)),
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),

              // Tarjeta Dark Mode (Transmisión de Rescate DMS)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: theme.colorScheme.tertiary, size: 16),
                        const SizedBox(width: 8),
                        Text('TRANSMISIÓN DE RESCATE (DMS)', style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(coords.dmsFormat, style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    const SizedBox(height: 24),
                    Divider(color: theme.colorScheme.tertiary.withOpacity(0.5), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PROTOCOLO ACTIVO', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.dangerState, shape: BoxShape.circle)),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Gráfico Perfil de Elevación
              Text('[GRÁFICO - PERFIL DE ELEVACIÓN DE RUTA]', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.tertiary, width: 1),
                ),
                padding: const EdgeInsets.only(right: 16, left: 0, top: 16, bottom: 8),
                child: elevationHistory.isEmpty
                    ? Center(
                        child: Text(
                          'Cargando datos topográficos...',
                          style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 10),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: 24, // 25 valores en el historial como máximo
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: theme.colorScheme.tertiary.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 10),
                                    textAlign: TextAlign.right,
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: elevationHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              color: theme.colorScheme.primary,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              )
            ],
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        error: (err, stack) => Center(child: Text('Error GPS:\n$err', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.dangerState))),
      ),
    );
  }

  Widget _buildLightCard(BuildContext context, {required String title, required Widget content, IconData? icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: theme.colorScheme.tertiary, size: 16), const SizedBox(width: 8)],
              Text(title, style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
