import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_form_model.dart';

class LoginForm extends StackedView<LoginFormModel> {

  final TextEditingController emailController;
  final TextEditingController passwordController;

  final VoidCallback onLogin;
  final VoidCallback onNavigateToRegister;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onNavigateToRegister,
  });

  @override
  Widget builder(BuildContext context, LoginFormModel viewModel, _) { // On utilise _ plutot que "Widget? child" par convention car on n'a pas besoin de ce dernier
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(labelText: "Adresse mail"),
          keyboardType: TextInputType.emailAddress,
        ),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(labelText: "Mot de passe"),
          keyboardType: TextInputType.visiblePassword,
        ),
        ElevatedButton(
            onPressed: (onLogin), child: Text("Se connecter")),
        ElevatedButton(
            onPressed: (onNavigateToRegister), child: Text("Créer un compte"))
      ],
    );
  }

  @override //Obligatoire car extends StackView
  LoginFormModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginFormModel();
}
