import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'register_form_model.dart';

class RegisterForm extends StackedView<RegisterFormModel> {
  const RegisterForm({super.key});

  @override
  Widget builder(
    BuildContext context,
    RegisterFormModel viewModel,
    Widget? child,
  ) {
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

  @override
  RegisterFormModel viewModelBuilder(
    BuildContext context,
  ) =>
      RegisterFormModel();
}
