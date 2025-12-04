import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorMessage;

  Future login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    clearErrorMessage();

    print("Tentative de connexion : $email / $password");
    if (email.isEmpty || password.isEmpty) {
      errorMessage = "les champs ne peuvent pas être vide.";
      rebuildUi();
      print(errorMessage!); // en attendant
      return;
    }
    final authResponse = await _authenticationService.loginWithEmail(
        email: email, password: password);
    if (!authResponse.hasError) {
      return; // La redirection se fait dans le listener dans StartupViewModel
    }
    //TODO: Faire un mapper pour les erreurs de Firebase, éviter de signaler via les erreurs qu'un compte est bien enregistré dans l'app
    errorMessage = authResponse.errorMessage;
    rebuildUi();
  }

  void navigateToRegister() {
    _navigationService.replaceWithRegisterView();
  }

  //TODO: Voir avec ELies à quel moment overrider un dispose (quand y'a des controllers?)
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void clearErrorMessage() {
    errorMessage = null;
    rebuildUi();
  }
}
