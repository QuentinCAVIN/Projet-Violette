import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_form_model.dart';

class LoginForm extends StackedView<LoginFormModel> {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? authError;

  final VoidCallback onLogin;
  final VoidCallback onNavigateToRegister;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onNavigateToRegister,
    this.authError,
  });

  @override
  Widget builder(BuildContext context, LoginFormModel viewModel, _) {
    // On utilise _ plutot que "Widget? child" par convention car on n'a pas besoin de ce dernier
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
        //TODO Voir avec ELies si on peut faire un Widget avec le message d'erreur (utilisé dans 2 endroits)
        //********************************
        // Affichage du message d'erreur *
        //********************************
        if (authError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              authError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        //*******************************
        ElevatedButton(onPressed: (onLogin), child: Text("Se connecter")),
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
