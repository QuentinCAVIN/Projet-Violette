import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

class LoginFormModel extends BaseViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _navigationService = locator<NavigationService>();

  void login() {
    print("Tentative de connexion" + emailController.text + passwordController.text);
  }

  void register() {
    _navigationService.replaceWithRegisterView();
  }
}
