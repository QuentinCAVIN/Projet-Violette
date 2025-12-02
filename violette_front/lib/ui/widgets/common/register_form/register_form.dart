import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'register_form_model.dart';

import 'package:violette_front/ui/views/register/register_viewmodel.dart';

class RegisterForm extends ViewModelWidget<RegisterViewModel> { // TODO Question ELies : la j'ai gardé une Classe Stacked, mais ça crée un couplage fort avec la vue.
  const RegisterForm({super.key,});                             // Et au final j'ai 3 WIdget et 3 classes différentes extend

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
        ElevatedButton(
          onPressed: (viewModel.register),
          child: Text("Créer mon compte "),
        ),
        ElevatedButton(
          onPressed: (viewModel.displayLoginView),
          child: Text("Compte existant"),
        )
      ],
    );
  }

  RegisterFormModel viewModelBuilder(
    BuildContext context,
  ) =>
      RegisterFormModel();
}
