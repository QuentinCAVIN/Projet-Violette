```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Note: Pour utiliser GoRouter, il faut ajouter la dépendance :
// flutter pub add go_router
import 'package:go_router/go_router.dart';

// --- LIVRABLE C5.1 : ThemeData Material 3 ---
// Mise en œuvre du Design System défini précédemment.

class AppTheme {
  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF6A1B9A), // Violet Profond
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE1BEE7),
      onPrimaryContainer: Color(0xFF311B92),
      secondary: Color(0xFFEC407A), // Rose Vif
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFF8BBD0),
      onSecondaryContainer: Color(0xFF880E4F),
      tertiary: Color(0xFF1A237E), // Bleu Indigo Profond
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFEF5350), // Rouge Doux
      onError: Color(0xFFFFFFFF),
      background: Color(0xFF121212), // Gris Presque Noir
      onBackground: Color(0xFFE0E0E0),
      surface: Color(0xFF1E1E1E), // Gris pour les cartes
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFFBDBDBD), // Texte secondaire
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 57,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
    ),
  );
}

// --- LIVRABLE C5.2 : Widget Réutilisable ---

enum AvailabilityStatus { confirmed, pending, conditional, declined }

class AvailabilityStatusChip extends StatelessWidget {
  final AvailabilityStatus status;

  const AvailabilityStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = _getStatusProperties(status);

    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: textColor, letterSpacing: 1.1),
        ),
      ),
    );
  }

  // Helper pour mapper le statut aux propriétés visuelles
  (String, Color, Color) _getStatusProperties(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.confirmed:
        return ('Confirmé', const Color(0xFF4CAF50), Colors.white);
      case AvailabilityStatus.pending:
        return ('En attente', const Color(0xFFBDBDBD), Colors.black);
      case AvailabilityStatus.conditional:
        return ('Conditionnel', const Color(0xFFFFCA28), Colors.black);
      case AvailabilityStatus.declined:
        return ('Refusé', const Color(0xFFEF5350), Colors.white);
    }
  }
}


// --- LIVRABLE C5.3 : Structure de Navigation ---
// Exemple simple avec GoRouter, montrant la navigation principale (BottomNav)
// et une sous-route (détail d'une date).

// 1. Définir les routes
final GoRouter router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    // La route "shell" pour gérer la barre de navigation persistante
    ShellRoute(
      builder: (context, state, child) {
        // L'UI de la BottomNavigationBar irait ici
        // return MainScaffold(child: child);
        return child; // Simplifié pour l'exemple
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Placeholder(), // DashboardScreen()
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const Placeholder(), // CalendarScreen()
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const Placeholder(), // MessagesScreen()
        ),
      ],
    ),
    // Route détaillée accessible depuis n'importe où
    GoRoute(
      path: '/date/:id',
      builder: (context, state) {
        final dateId = state.pathParameters['id'];
        // return DateDetailScreen(dateId: dateId);
        return Scaffold(body: Center(child: Text('Détail de la date: $dateId')));
      },
    ),
  ],
);

// 2. Intégrer dans le MaterialApp
class VioletteApp extends StatelessWidget {
  const VioletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Violette',
      theme: AppTheme.themeData,
      routerConfig: router,
    );
  }
}
```
