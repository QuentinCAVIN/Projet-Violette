import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

class RegisterFormModel extends BaseViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final _navigationService = locator<NavigationService>();

  void register() {
    print("Tentative d'inscription");
  }

  void displayLoginView() {
    _navigationService.replaceWithLoginView();
  }
}
