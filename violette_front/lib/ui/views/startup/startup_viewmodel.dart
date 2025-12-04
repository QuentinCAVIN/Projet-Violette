import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 2));

    // This is where you can make decisions on where your app should navigate when
    // you have custom startup logic

    _authenticationService.authStateChanges.listen((user) {
      if (user != null) {
        _navigationService.replaceWithHomeView();
      } else {
        _navigationService.replaceWithLoginView();
      }
    });
  }
}

//TODO : créer un CurrentUserService qui charge le User courant dans StartupView
// pour éviter de recharger VioletteUser dans chaque View