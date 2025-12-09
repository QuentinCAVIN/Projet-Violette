import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:violette_front/ui/views/register/register_viewmodel.dart';

import '../register_view.form.dart';

class RegisterForm extends ViewModelWidget<RegisterViewModel> {
  // Note pour moi-même:
  // Le ViewModelWidget est lié au RegisterViewModel et peu donc accéder a toutes ses méthodes et attribut.
  // Comme RegisterViewModel extend FormViewModel on a acces aux ValidationMessage.
  // En revanche on est obligé de passer les TextEditingController via le constructeur car les controller sont générés par stacked
  // à partir de l'annotation @FormView et ne sont lié qu'a RegisterView. D'ou l'approche "hybride"

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;

  const RegisterForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
  });

  @override
  Widget build(
    BuildContext context,
    RegisterViewModel viewModel,
  ) {
    return Column(
      children: [
        TextFormField(
          controller: firstNameController,
          decoration: InputDecoration(
            labelText: "Prénom",
            errorText: viewModel.firstNameValidationMessage,
          ),
          keyboardType: TextInputType.name,
        ),
        TextFormField(
          controller: lastNameController,
          decoration: InputDecoration(
            labelText: "Nom",
            errorText: viewModel.lastNameValidationMessage,
          ),
          keyboardType: TextInputType.name,
        ),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: "Adresse mail",
            errorText: viewModel.emailValidationMessage,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: "Mot de passe",
            errorText: viewModel.passwordValidationMessage,
          ),
          keyboardType: TextInputType.visiblePassword,
        ),
        TextFormField(
          controller: passwordConfirmationController,
          decoration: InputDecoration(
            labelText: "Confirmation du mot de passe",
            errorText: viewModel.passwordConfirmationValidationMessage,
          ),
          keyboardType: TextInputType.visiblePassword,
        ),
        //********************************
        // Affichage du message d'erreur *
        //********************************
        if (viewModel.globalErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              viewModel.globalErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        //*******************************
        ElevatedButton(
          onPressed: (viewModel.register),
          child: Text("Créer mon compte "),
          style: Theme.of(context)
              .elevatedButtonTheme
              .style, // TODO appliquer le theme partout comme ceci
          // Le theme est appellé dans le main
        ),
        ElevatedButton(
          onPressed: (viewModel.navigateToLogin),
          child: Text("Compte existant"),
        )
      ],
    );
  }
}
