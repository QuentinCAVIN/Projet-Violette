import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

class RegisterViewModel extends BaseViewModel {

  final _navigationService = locator<NavigationService>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
  TextEditingController();

  void register() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final passwordConfirmation = passwordConfirmationController.text;
    if (password != passwordConfirmation) {
      print("Les mots de passe ne correspondent pas");
      return;
    }
    print("Tentative d'inscription de l'adresse mail : $email avec le mot de passe : $password");
  }

  void displayLoginView() {
    _navigationService.replaceWithLoginView();
  }
}
