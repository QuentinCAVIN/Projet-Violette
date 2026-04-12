import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/repositories/user_repository.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _userRepository = locator<UserRepository>();

  /// Message d'erreur technique à afficher sur la StartupView quand le backend
  /// est inaccessible. Null tant qu'aucune erreur n'est survenue.
  String? startupError;

  /// Routage initial déterministe après le splash.
  ///
  /// Trois chemins possibles :
  /// - Pas de session Firebase                  → LoginView
  /// - Session Firebase + profil backend trouvé → HomeView
  /// - Session Firebase + profil backend absent → logout Firebase + LoginView
  ///   (cas typique en dev après réinitialisation de la base H2 ; état incohérent
  ///   en production)
  /// - Erreur réseau / backend inaccessible     → erreur affichée sur StartupView
  ///
  /// Ne pas s'abonner à [authStateChanges] pour naviguer : à l'inscription,
  /// Firebase connecte l'utilisateur avant [POST /api/users] ; un listener global
  /// enverrait vers la Home avant que le profil backend n'existe.
  Future<void> runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 2));

    final firebaseUser = _authenticationService.currentUser;
    if (firebaseUser == null) {
      _navigationService.replaceWithLoginView();
      return;
    }

    try {
      final profile = await _userRepository.getUser(firebaseUser.uid);

      if (profile != null) {
        _navigationService.replaceWithHomeView();
      } else {
        // Profil backend absent pour un utilisateur Firebase connu.
        // On déconnecte Firebase pour repartir d'un état cohérent : l'utilisateur
        // devra créer un nouveau compte via RegisterView.
        await _authenticationService.logout();
        _navigationService.replaceWithLoginView();
      }
    } catch (e) {
      // Backend inaccessible ou erreur réseau — on ne navigue pas aveuglément.
      startupError =
          'Impossible de joindre le serveur au démarrage.\n'
          'Vérifie que Quarkus tourne (profil firebase + FIREBASE_PROJECT_ID) '
          'et que adb reverse est actif si tu es sur téléphone USB.\n\n$e';
      rebuildUi();
    }
  }
}
