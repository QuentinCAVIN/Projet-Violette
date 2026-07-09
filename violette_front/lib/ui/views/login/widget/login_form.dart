import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/views/login/login_viewmodel.dart';

import '../login_view.form.dart';

class LoginForm extends ViewModelWidget<LoginViewModel> {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context, LoginViewModel viewModel) {
    return Column(
      children: [
        //Email
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            errorText: viewModel.emailValidationMessage,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        //Mot de passe
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: 'Mot de passe',
            errorText: viewModel.passwordValidationMessage,
          ),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        // DETTE-7 : extraire un widget partagé pour le message d'erreur global (login et register)
        if (viewModel.globalErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Text(
              viewModel.globalErrorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),

        // Bouton "Se connecter"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.login,
            child: const Text('Se connecter'),
          ),
        ),

        const SizedBox(height: 20),

        // Lien créer un compte
        TextButton(
          onPressed: viewModel.navigateToRegister,
          child: const Text('Nouveau ? Créer un compte'),
        ),
      ],
    );
  }
}
