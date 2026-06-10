import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_providers.dart';
import '../../clinometer/presentation/clinometer_providers.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isElevated = ref.watch(suspensionModeProvider).value ?? false;
    final thresholds = ref.watch(thresholdsProvider).value;
    final currentPitchMax = thresholds?['pitch'] ?? 35.0;
    final currentRollMax = thresholds?['roll'] ?? 30.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.change_history, size: 24, color: AppTheme.primaryNavy),
            const SizedBox(width: 8),
            const Text('TRAILGAUGE 4X4', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('AJUSTES Y\nCALIBRACIÓN', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.primaryNavy, height: 1.1)),
            const SizedBox(height: 8),
            const Text('Configuración técnica de sensores inerciales y parámetros de seguridad activa.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),

            // SECCIÓN 1: Calibración
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.borderGray, width: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MÓDULO DE INERCIA', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  const Text('Calibración de Nivel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 8),
                  const Text('Establece el horizonte artificial basado en la posición actual del vehículo. Asegúrese de estar en una superficie perfectamente nivelada.', style: TextStyle(fontSize: 12, color: AppTheme.primaryNavy, height: 1.5)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final attitude = ref.read(vehicleAttitudeStreamProvider).value;
                        final currentOffsets = await ref.read(calibrationOffsetsProvider.future);
                        
                        if (attitude != null) {
                          // BUG FIX: La pantalla muestra el valor ya compensado.
                          // Para obtener el valor "crudo" real del sensor, sumamos el offset actual.
                          final rawPitch = attitude.pitch + (currentOffsets['pitch'] ?? 0.0);
                          final rawRoll = attitude.roll + (currentOffsets['roll'] ?? 0.0);
                          
                          await ref.read(settingsRepositoryProvider).saveCalibrationOffsets(rawPitch, rawRoll);
                          
                          // Forzamos la recarga de los offsets para que el StreamNotifier se reinicie
                          ref.invalidate(calibrationOffsetsProvider);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sistema calibrado a 0°')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('CALIBRAR A CERO (0°)', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // SECCIÓN 1.5: Imagen Render 3D Placeholder
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0), // Gris claro simula fondo de renderizado 3D
                border: Border.all(color: AppTheme.borderGray, width: 1.5),
              ),
              alignment: Alignment.bottomLeft,
              child: Container(
                color: AppTheme.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text('ESTADO DEL SENSOR\nACTIVO // 45Hz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 12),

            // SECCIÓN 2: Alertas de Seguridad
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.borderGray, width: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: AppTheme.primaryNavy, size: 20),
                      SizedBox(width: 8),
                      Text('ALERTAS DE SEGURIDAD', style: TextStyle(color: AppTheme.primaryNavy, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSliderControl(context, ref, 'LÍMITE ROLL', currentRollMax, true, currentPitchMax),
                  const SizedBox(height: 24),
                  _buildSliderControl(context, ref, 'LÍMITE PITCH', currentPitchMax, false, currentRollMax),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // SECCIÓN 3: Algoritmo de Suspensión (Checkboxes Cuadrados Custom)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.borderGray, width: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ALGORITMO DE ESTABILIDAD // SUSPENSIÓN', style: TextStyle(color: AppTheme.primaryNavy, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  const Text('Seleccione la geometría de suspensión para optimizar los cálculos de transferencia de masas.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 20),
                  
                  _buildCheckOption('OEM STOCK DE FÁBRICA', !isElevated, () {
                    ref.read(settingsRepositoryProvider).saveSuspensionMode(false);
                    ref.invalidate(suspensionModeProvider);
                  }),
                  const SizedBox(height: 12),
                  _buildCheckOption('MODIFICADA (ELEVADA)', isElevated, () {
                    ref.read(settingsRepositoryProvider).saveSuspensionMode(true);
                    ref.invalidate(suspensionModeProvider);
                  }),
                  
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline, size: 14, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(child: Text('EL MODO "ELEVADA" COMPENSA EL DESPLAZAMIENTO DEL CENTRO DE GRAVEDAD EN VEHÍCULOS CON KITS DE ELEVACIÓN.', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold))),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            // Footer (Wireframe bottom info)
            const Text('FIRMWARE: v2.4.0-STABLE\nHARDWARE: TG-REV-B\nLAST SYNC: 2026-06-09 14:32', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.0, height: 1.5)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppTheme.primaryNavy : AppTheme.borderGray, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryNavy, width: 2),
                color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderControl(BuildContext context, WidgetRef ref, String label, double value, bool isRoll, double otherValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primaryNavy, letterSpacing: 1.0)),
            Text('${value.toInt()}°', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryNavy)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.primaryNavy,
            inactiveTrackColor: AppTheme.borderGray,
            thumbColor: AppTheme.primaryNavy,
            overlayColor: AppTheme.primaryNavy.withOpacity(0.1),
            trackHeight: 2.0,
          ),
          child: Slider(
            value: value,
            min: 10,
            max: 60,
            divisions: 50,
            onChanged: (val) async {
              if (isRoll) {
                await ref.read(settingsRepositoryProvider).saveThresholds(otherValue, val);
              } else {
                await ref.read(settingsRepositoryProvider).saveThresholds(val, otherValue);
              }
              ref.invalidate(thresholdsProvider);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('10°', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('60°', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        )
      ],
    );
  }
}
