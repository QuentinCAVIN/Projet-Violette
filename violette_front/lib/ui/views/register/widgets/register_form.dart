import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/views/register/register_viewmodel.dart';

import '../../../../models/enums/role.dart';
import '../register_view.form.dart';

/// Texte saisi — foncé pour contraste sur le verre clair des écrans auth.
const _authFieldTextStyle = TextStyle(
  color: VioletteTheme.textOnCard,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

/// Placeholder — ton atténué lisible sur fond clair (surcharge du thème global).
const _authFieldHintStyle = TextStyle(
  color: VioletteTheme.textOnCardSecondary,
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

/// Formulaire d'inscription avec approche hybride Stacked :
/// les [TextEditingController] sont passés au constructeur car ils sont générés
/// par `@FormView` sur [RegisterView], pas sur ce widget.
class RegisterForm extends ViewModelWidget<RegisterViewModel> {
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
          style: _authFieldTextStyle,
          decoration: InputDecoration(
            hintText: 'Prénom',
            hintStyle: _authFieldHintStyle,
            errorText: viewModel.firstNameValidationMessage,
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),

        // Champ Nom
        TextFormField(
          controller: lastNameController,
          style: _authFieldTextStyle,
          decoration: InputDecoration(
            hintText: 'Nom',
            hintStyle: _authFieldHintStyle,
            errorText: viewModel.lastNameValidationMessage,
          ),
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),

        // Champ Email
        TextFormField(
          controller: emailController,
          style: _authFieldTextStyle,
          decoration: InputDecoration(
            hintText: 'Email',
            hintStyle: _authFieldHintStyle,
            errorText: viewModel.emailValidationMessage,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Boutton radio
        RadioGroup<Role>(
          groupValue: viewModel.role,
          onChanged: (Role? value) {
            viewModel.onRoleChanged(value!);
          },
          child: Column(
            children: <Widget>[
              ListTile(
                title: const Text('Artiste'),
                leading: const Radio<Role>(value: Role.artist),
                onTap: () => viewModel.onRoleChanged(Role.artist),
              ),
              ListTile(
                title: const Text('Manager'),
                leading: const Radio<Role>(value: Role.manager),
                onTap: () => viewModel.onRoleChanged(Role.manager),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Champ Mot de passe
        TextFormField(
          controller: passwordController,
          style: _authFieldTextStyle,
          decoration: InputDecoration(
            hintText: 'Mot de passe',
            hintStyle: _authFieldHintStyle,
            errorText: viewModel.passwordValidationMessage,
          ),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: 16),

        // Champ Confirmation du mot de passe
        TextFormField(
          controller: passwordConfirmationController,
          style: _authFieldTextStyle,
          decoration: InputDecoration(
            hintText: 'Confirmation du mot de passe',
            hintStyle: _authFieldHintStyle,
            errorText: viewModel.passwordConfirmationValidationMessage,
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
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
