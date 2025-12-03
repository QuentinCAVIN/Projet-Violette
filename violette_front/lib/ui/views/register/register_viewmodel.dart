import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

class RegisterViewModel extends BaseViewModel {


  final _navigationService = locator<NavigationService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
  TextEditingController();

  Future register() async {

    final email = emailController.text.trim();
    final password = passwordController.text;
    final passwordConfirmation = passwordConfirmationController.text;
    if (password != passwordConfirmation) {
      print("Les mots de passe ne correspondent pas");
      return;
    }
    print("Tentative d'inscription de l'adresse mail : $email avec le mot de passe : $password");
    final result = await _authenticationService.createAccountWithEmail(email: email, password: password);

    if (result.hasError) {
      print ("Erreur lors de l'inscription : ${result.errorMessage}");
      return;
    }
    print("Inscription réussie");
  }

  void navigateToLogin() {
    _navigationService.replaceWithLoginView();
  }
}
