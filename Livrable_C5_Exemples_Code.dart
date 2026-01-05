```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';

// --- LIVRABLE C5.1 : ThemeData Material 3 ---
// Mise en œuvre du Design System défini dans Livrable_C4.
// Note : L'implémentation finale se trouve dans `violette_front/lib/ui/common/app_theme.dart`.

class AppTheme {
  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF6A1B9A), // Violet Profond
      onPrimary: Color(0xFFFFFFFF),
      // ... autres couleurs
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(fontSize: 57),
      // ... autres styles de texte
    ),
  );
}

// --- LIVRABLE C5.2 : Widget Réutilisable ---
// Exemple de spécification pour un widget réutilisable.
// Note : L'implémentation finale et complète de ce widget se trouve dans :
// `violette_front/lib/ui/widgets/common/availability_status_chip.dart`.

enum AvailabilityStatus { confirmed, pending, conditional, declined }

class AvailabilityStatusChip extends StatelessWidget {
  final AvailabilityStatus status;
  const AvailabilityStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Le code de ce widget a été déplacé dans son propre fichier pour une meilleure organisation.
    // Ce fichier sert d'exemple de la proposition initiale.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.toString().toUpperCase()),
    );
  }
}


// --- LIVRABLE C5.3 : Structure de Navigation (Manuelle, idiomatique à Stacked) ---
// Exemple illustrant l'approche de navigation manuelle utilisée dans le projet.
// Cela remplace l'exemple précédent qui utilisait GoRouter pour être cohérent.

// 1. Définir les constantes de routes (dans app/app.dart)
const String loginViewRoute = '/login';
const String dateDetailViewRoute = '/date-detail';

// 2. Créer un routeur manuel (dans app/router.dart)
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginViewRoute:
        // return MaterialPageRoute(builder: (_) => const LoginView());
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Login'))));
      case dateDetailViewRoute:
        final String dateId = settings.arguments as String;
        // return MaterialPageRoute(builder: (_) => DateDetailView(dateId: dateId));
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('Détail de la date: $dateId'))));
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Route inconnue'))));
    }
  }
}

// 3. Utiliser le NavigationService pour naviguer
// (Exemple d'utilisation dans un ViewModel)
class ExampleViewModel {
  final NavigationService _navigationService = NavigationService();

  void navigateToLogin() {
    _navigationService.navigateTo(loginViewRoute);
  }

  void navigateToDateDetails(String dateId) {
    _navigationService.navigateTo(
      dateDetailViewRoute,
      arguments: dateId,
    );
  }
}

// 4. Intégrer dans le MaterialApp (dans main.dart)
class VioletteApp extends StatelessWidget {
  const VioletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Violette',
      theme: AppTheme.themeData,
      navigatorKey: StackedService.navigatorKey,
      initialRoute: loginViewRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
```
