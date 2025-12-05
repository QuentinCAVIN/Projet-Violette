import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:violette_front/ui/widgets/common/login_form/login_form.dart';
import 'package:violette_front/ui/widgets/common/login_header/login_header.dart';

import 'login_view.form.dart';
import 'login_viewmodel.dart';

@FormView(
  fields: [
    FormTextField(name: 'email'),
    FormTextField(name: 'password'),
  ],
)
class LoginView extends StackedView<LoginViewModel> with $LoginView {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4016FF), Color(0xFFCF58FF)],
              ),
            ),
          ),
          Center(
            child: Padding(
              //TODO Question Elies: Coté register j'ai wrappé Padding dans un WIdget SingleScrollView
              // Je devrais faire la même chose ici pour anticiper des écran vraiment trop petit?
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // grace à ça Column prends uniquement la taille de ses enfants et donc le Center au dessus fera effet.
                //(= rien a centrer sur l'axe vertical sinon puisque la colonne occupe toute l'espace)
                children: [
                  LoginHeader(),
                  LoginForm(
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onViewModelReady(LoginViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(LoginViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }

  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel();
}
