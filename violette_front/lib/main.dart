import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.dart';
import 'package:violette_front/app/router.dart';
import 'package:violette_front/ui/common/app_theme.dart';

void main() {
  // 1. Initialise le Service Locator pour l'injection de dépendances
  setupLocator();

  // 2. Lance l'application Flutter
  runApp(const VioletteApp());
}

class VioletteApp extends StatelessWidget {
  const VioletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Violette',
      // Utilise le thème centralisé depuis la classe AppTheme.
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,

      // --- Configuration de la Navigation Stacked ---
      // Utilise la clé du NavigationService pour que Stacked puisse contrôler la navigation
      navigatorKey: StackedService.navigatorKey,

      // La route initiale de l'application
      initialRoute: startupViewRoute,

      // La fonction qui génère les routes pour l'application
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
