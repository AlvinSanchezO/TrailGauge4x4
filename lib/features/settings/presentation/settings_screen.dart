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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('AJUSTES Y\nCALIBRACIÓN', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, height: 1.1)),
            const SizedBox(height: 8),
            Text('Configuración técnica de sensores inerciales y parámetros de seguridad activa.', style: TextStyle(fontSize: 12, color: theme.colorScheme.tertiary)),
            const SizedBox(height: 24),

            // SECCIÓN 1: Calibración
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor, 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MÓDULO DE INERCIA', style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Text('Calibración de Nivel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text('Establece el horizonte artificial basado en la posición actual del vehículo. Asegúrese de estar en una superficie perfectamente nivelada.', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, height: 1.5)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final attitude = ref.read(vehicleAttitudeStreamProvider).value;
                        final currentOffsets = await ref.read(calibrationOffsetsProvider.future);
                        
                        if (attitude != null) {
                          final rawPitch = attitude.pitch + (currentOffsets['pitch'] ?? 0.0);
                          final rawRoll = attitude.roll + (currentOffsets['roll'] ?? 0.0);
                          
                          await ref.read(settingsRepositoryProvider).saveCalibrationOffsets(rawPitch, rawRoll);
                          
                          ref.invalidate(calibrationOffsetsProvider);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sistema calibrado a 0°')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
              ),
              alignment: Alignment.bottomLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topRight: Radius.circular(8)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('ESTADO DEL SENSOR\nACTIVO // 45Hz', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 12),

            // SECCIÓN 2: Alertas de Seguridad
            Container(
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
                      Icon(Icons.warning_amber_rounded, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('ALERTAS DE SEGURIDAD', style: TextStyle(color: theme.colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
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

            // SECCIÓN 3: Algoritmo de Suspensión
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor, 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ALGORITMO DE ESTABILIDAD // SUSPENSIÓN', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Text('Seleccione la geometría de suspensión para optimizar los cálculos de transferencia de masas.', style: TextStyle(fontSize: 11, color: theme.colorScheme.tertiary)),
                  const SizedBox(height: 20),
                  
                  _buildCheckOption(context, 'OEM STOCK DE FÁBRICA', !isElevated, () {
                    ref.read(settingsRepositoryProvider).saveSuspensionMode(false);
                    ref.invalidate(suspensionModeProvider);
                  }),
                  const SizedBox(height: 12),
                  _buildCheckOption(context, 'MODIFICADA (ELEVADA)', isElevated, () {
                    ref.read(settingsRepositoryProvider).saveSuspensionMode(true);
                    ref.invalidate(suspensionModeProvider);
                  }),
                  
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 8),
                      Expanded(child: Text('EL MODO "ELEVADA" COMPENSA EL DESPLAZAMIENTO DEL CENTRO DE GRAVEDAD EN VEHÍCULOS CON KITS DE ELEVACIÓN.', style: TextStyle(fontSize: 8, color: theme.colorScheme.tertiary, fontWeight: FontWeight.bold))),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            // Footer
            Text('FIRMWARE: v2.4.0-STABLE\nHARDWARE: TG-REV-B\nLAST SYNC: 2026-06-09 14:32', style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 10, letterSpacing: 1.0, height: 1.5)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckOption(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.tertiary, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.colorScheme.primary, width: 2),
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              ),
              child: isSelected ? Icon(Icons.check, size: 14, color: theme.scaffoldBackgroundColor) : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderControl(BuildContext context, WidgetRef ref, String label, double value, bool isRoll, double otherValue) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: theme.colorScheme.primary, letterSpacing: 1.0)),
            Text('${value.toInt()}°', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.colorScheme.primary)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.tertiary,
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.1),
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
          children: [
            Text('10°', style: TextStyle(fontSize: 10, color: theme.colorScheme.tertiary)),
            Text('60°', style: TextStyle(fontSize: 10, color: theme.colorScheme.tertiary)),
          ],
        )
      ],
    );
  }
}
