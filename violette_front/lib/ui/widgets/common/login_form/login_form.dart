import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/views/login/login_viewmodel.dart';

import '../../../views/login/login_view.form.dart';


class LoginForm extends ViewModelWidget<LoginViewModel> {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? authError = null;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context, LoginViewModel viewModel) {
    return Column(
      children: [
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
        //TODO Voir avec ELies si on peut faire un Widget avec le message d'erreur (utilisé dans 2 endroits)
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
        ElevatedButton(onPressed: viewModel.login, child: const Text("Se connecter")),
        ElevatedButton(
          onPressed: viewModel.navigateToRegister,
          child: const Text("J'ai déja un compte"),
        )
      ],
    );
  }
}
