import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';

// --- 1. Service Locator ---
// Instance globale de GetIt pour l'injection de dépendances.
final locator = GetIt.instance;

/// Enregistre manuellement les services en tant que singletons.
/// C'est l'équivalent manuel de la section `dependencies` de `@StackedApp`.
void setupLocator() {
  // Services de base de Stacked
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => BottomSheetService());

  // Services spécifiques à l'application (à ajouter plus tard)
  // locator.registerLazySingleton(() => VioletteUserService());
  // locator.registerLazySingleton(() => ShowDateService());
}


// --- 2. Constantes des Routes ---
// Noms des routes utilisés pour la navigation.
// C'est l'équivalent manuel de ce que `@StackedApp` génère pour le routeur.

const String startupViewRoute = '/';
const String mainViewRoute = '/main';
const String loginViewRoute = '/login';
const String dateDetailViewRoute = '/date-detail';
// ... ajouter d'autres constantes de routes ici au besoin.
