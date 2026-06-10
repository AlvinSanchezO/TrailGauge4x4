import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation_menu/presentation/navigation_menu.dart';

void main() {
  runApp(
    // ProviderScope es el motor global de estado para Riverpod
    const ProviderScope(
      child: TrailGaugeApp(),
    ),
  );
}

class TrailGaugeApp extends StatelessWidget {
  const TrailGaugeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrailGauge 4x4',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tacticalTheme, // Inyectamos la UI de alto contraste
      home: const NavigationMenu(),
    );
  }
}
