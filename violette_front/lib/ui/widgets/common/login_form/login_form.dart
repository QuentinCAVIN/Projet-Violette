import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_form_model.dart';

class LoginForm extends StatelessWidget { // TODO Question ELies : J'ai été obligé de changer le StackedView, ça va pas à l'encotre de l'utilisation de Stacked

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
  Widget build(BuildContext context) {
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

  @override //TODO Question ELies : ça sert plus à rien du coup ça (ça passe le context au model?) on supprime les model des WIdget?
  LoginFormModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginFormModel();
}
