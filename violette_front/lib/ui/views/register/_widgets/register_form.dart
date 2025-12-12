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
        //Prénom
        TextFormField(
          controller: firstNameController,
          decoration: InputDecoration(
            hintText: 'Prénom',
            errorText: viewModel.firstNameValidationMessage,
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),

        // Champ Nom
        TextFormField(
          controller: lastNameController,
          decoration: InputDecoration(
            hintText: 'Nom',
            errorText: viewModel.lastNameValidationMessage,
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),

        // Champ Email
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            errorText: viewModel.emailValidationMessage,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Champ Mot de passe
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: 'Mot de passe',
            errorText: viewModel.passwordValidationMessage,
          ),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: 16),

        // Champ Confirmation du mot de passe
        TextFormField(
          controller: passwordConfirmationController,
          decoration: InputDecoration(
            hintText: 'Confirmation du mot de passe',
            errorText: viewModel.passwordConfirmationValidationMessage,
          ),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),

        //TODO Voir avec ELies si on peut faire un Widget avec le message d'erreur (utilisé dans 2 endroits)
        //********************************
        // Affichage du message d'erreur *
        //********************************
        if (viewModel.globalErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Text(
              viewModel.globalErrorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        //*******************************
        const SizedBox(height: 24),

        // Bouton de validation
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.submitRegisterForm,
            child: const Text('Créer mon compte'),
          ),
        ),

        const SizedBox(height: 20),

        TextButton(
          onPressed: viewModel.navigateToLogin,
          child: const Text('Compte existant'),
        ),
      ],
    );
  }
}
