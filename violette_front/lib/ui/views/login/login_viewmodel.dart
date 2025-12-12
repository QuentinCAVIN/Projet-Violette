import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

import '../register/register_view.form.dart';

class LoginViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();

  String? globalErrorMessage;
  bool formAlreadyValidatedOnce = false;

  @override
  void setFormStatus() {
    // Réinitialisation des messages d'erreur
    setEmailValidationMessage(null);
    setPasswordValidationMessage(null);

    // Ne pas afficher les erreurs avant la validation du formulaire
    if (!formAlreadyValidatedOnce) {
      return;
    }

    // Email
    if (emailValue == null || emailValue!.trim().isEmpty) {
      setEmailValidationMessage("L'adresse mail est obligatoire");
    } else if (!emailValue!.contains('@')) {
      setEmailValidationMessage("Adresse mail invalide");
    }

    // Mot de passe
    if (passwordValue == null || passwordValue!.isEmpty) {
      setPasswordValidationMessage("Le mot de passe est obligatoire");
    }
  }

  Future<void> login() async {
    formAlreadyValidatedOnce = true;
    globalErrorMessage = null;

    setFormStatus();
    rebuildUi();

    if (!isFormValid) {
      return;
    }

    final String email = emailValue!.trim().toLowerCase();
    final String password = passwordValue!;

    final authResult = await _authenticationService.loginWithEmail(
      email: email,
      password: password,
    );

    if (authResult.hasError) {
      //TODO Faire un mapper pour les erreurs de Firebase
      globalErrorMessage =
          "Combinaison adresse mail / mot de passe incorrecte.";
      print(authResult.errorMessage);
      rebuildUi();
      return;
    }
  }

  void navigateToRegister() {
    _navigationService.navigateToRegisterView();
  }
}
