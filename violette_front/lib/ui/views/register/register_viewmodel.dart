import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

import 'package:violette_front/ui/views/register/register_view.form.dart';

import '../../../models/enums/role.dart';
import '../../../services/violette_user_service.dart';
import 'package:violette_front/models/violette_user.dart';

class RegisterViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _userServices = locator<VioletteUserService>();

  String? globalErrorMessage;
  bool formAlreadyValidatedOnce = false;
  Role role = Role.artist;

  @override
  void setFormStatus() {
    // Réinitialisation des messages d'erreur
    setFirstNameValidationMessage(null);
    setLastNameValidationMessage(null);
    setEmailValidationMessage(null);
    setPasswordValidationMessage(null);
    setPasswordConfirmationValidationMessage(null);

    // Ne pas afficher les erreurs avant la validation du formulaire
    if (!formAlreadyValidatedOnce) {
      return;
    }

    // Prénom
    if (firstNameValue == null || firstNameValue!.trim().isEmpty) {
      setFirstNameValidationMessage('Le prénom est obligatoire');
    }

    // Nom
    if (lastNameValue == null || lastNameValue!.trim().isEmpty) {
      setLastNameValidationMessage('Le nom est obligatoire');
    }

    // Email
    if (emailValue == null || emailValue!.trim().isEmpty) {
      setEmailValidationMessage("L'adresse mail est obligatoire");
    } else if (!emailValue!.contains('@')) {
      setEmailValidationMessage("Adresse mail invalide");
    }

    // Mot de passe
    if (passwordValue == null || passwordValue!.length < 6) {
      setPasswordValidationMessage(
        'Mot de passe trop court (min. 6 caractères)',
      );
    }

    // Confirmation mot de passe
    if (passwordConfirmationValue != passwordValue) {
      setPasswordConfirmationValidationMessage(
        'Les mots de passe ne correspondent pas',
      );
    }
  }

  Future submitRegisterForm() async {
    formAlreadyValidatedOnce = true;
    globalErrorMessage = null;

    setFormStatus();
    rebuildUi();

    if (!isFormValid) {
      return;
    }

    final String email = emailValue!.trim().toLowerCase();
    final String password = passwordValue!;

    final authResult = await _authenticationService.createAccountWithEmail(
        email: email, password: password);

    //TODO: Faire un mapper pour les erreurs de Firebase,
    // éviter de signaler via les erreurs qu'un compte existe déja dans l'app
    if (authResult.hasError) {
      globalErrorMessage = authResult.errorMessage;
      rebuildUi();
      return;
    }
    // Inscription réussie
    final String userId = authResult.user!.uid;
    final String firstName = firstNameValue!.trim();
    final String lastName = lastNameValue!.trim();
    VioletteUser user = VioletteUser(
        uid: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        roles: [role]);
    await _userServices.addUser(user);
  }

  void navigateToLogin() {
    _navigationService.replaceWithLoginView();
  }

  void onRoleChanged(Role role) {
    this.role = role;
    rebuildUi();
  }
}

//TODO: METTRE EN PRATIQUE CERTAINES REGLES OPQUAST
//Règle n° 17 - La création d'un compte est soumise à un processus de confirmation. https://checklists.opquast.com/fr/assurance-qualite-web/la-creation-dun-compte-est-soumise-a-un-processus-de-confirmation
