import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:violette_front/ui/views/register/register_viewmodel.dart';

class RegisterForm extends ViewModelWidget<RegisterViewModel> {
  const RegisterForm({super.key,});

  @override
  Widget build(
    BuildContext context, RegisterViewModel viewModel,) {
    return Column(
      children: [
        TextFormField(
          controller: viewModel.emailController,
          decoration: InputDecoration(labelText: "Adresse mail"),
          keyboardType: TextInputType.emailAddress,
        ),
        TextFormField(
          controller: viewModel.passwordController,
          decoration: InputDecoration(labelText: "Mot de passe"),
          keyboardType: TextInputType.visiblePassword,
        ),
        TextFormField(
          controller: viewModel.passwordConfirmationController,
          decoration:
              InputDecoration(labelText: "Confirmation du mot de passe"),
          keyboardType: TextInputType.visiblePassword,
        ),
        //********************************
        // Affichage du message d'erreur *
        //********************************
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              viewModel.errorMessage!,
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
        ),
        ElevatedButton(
          onPressed: (viewModel.navigateToLogin),
          child: Text("Compte existant"),
        )
      ],
    );
  }

}
