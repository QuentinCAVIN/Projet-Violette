import 'package:flutter/material.dart';
import 'package:violette_front/app/app.dart';
import 'package:violette_front/ui/views/login/login_view.dart';
import 'package:violette_front/ui/views/main/main_view.dart';
import 'package:violette_front/ui/views/startup/startup_view.dart';

class AppRouter {
  /// Génère une route en fonction du nom et des arguments fournis.
  /// C'est l'équivalent manuel du `app.router.dart` généré.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case startupViewRoute:
        return MaterialPageRoute(builder: (_) => const StartupView());
      case mainViewRoute:
        return MaterialPageRoute(builder: (_) => const MainView());
      case loginViewRoute:
        return MaterialPageRoute(builder: (_) => const LoginView());
      // case dateDetailViewRoute:
      //   final String dateId = settings.arguments as String;
      //   return MaterialPageRoute(builder: (_) => DateDetailView(dateId: dateId));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Aucune route définie pour ${settings.name}'),
            ),
          ),
        );
    }
  }
}
