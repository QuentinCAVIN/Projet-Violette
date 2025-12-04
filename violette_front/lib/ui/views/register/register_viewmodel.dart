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

  String? errorMessage;

  Future register() async {

    final email = emailController.text.trim();
    final password = passwordController.text;
    final passwordConfirmation = passwordConfirmationController.text;
    if (password != passwordConfirmation) {
      errorMessage ="Les mots de passe ne correspondent pas"; // on peut pas utiliser les message de FirebaseAuthenticationService
      rebuildUi();
      return;
    }
    print("Tentative d'inscription de l'adresse mail : $email avec le mot de passe : $password");
    final result = await _authenticationService.createAccountWithEmail(email: email, password: password);

    //TODO: Faire un mapper pour les erreurs de Firebase, éviter de signaler via les erreurs qu' compte est bien enregistré dans l'app
    if (result.hasError) {
      errorMessage = result.errorMessage;
      rebuildUi();
      return;
    }
    print("Inscription réussie");
  }

  void navigateToLogin() {
    _navigationService.replaceWithLoginView();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }
}

//TODO: METTRE EN PRATIQUE CERTAINES REGLES OPQUAST
//Règle n° 17 - La création d'un compte est soumise à un processus de confirmation. https://checklists.opquast.com/fr/assurance-qualite-web/la-creation-dun-compte-est-soumise-a-un-processus-de-confirmation
