import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    print("Tentative de connexion : $email / $password");

    // TODO Appelle StackedFIrebaseAuth ici + voir ou placer le tracking de connexion de l'utilisateur (listening?)
    // _navigationService.replaceWithHomeView();
  }

  void navigateToRegister() {
    _navigationService.replaceWithRegisterView();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
