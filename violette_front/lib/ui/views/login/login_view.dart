import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/views/login/widget/login_form.dart';
import 'package:violette_front/ui/widgets/common/login_header/login_header.dart';
import 'package:violette_front/ui/widgets/common/sparkle_background/sparkle_background.dart';

import 'login_view.form.dart';
import 'login_viewmodel.dart';

@FormView(
  fields: [
    FormTextField(name: 'email'),
    FormTextField(name: 'password'),
  ],
)
class LoginView extends StackedView<LoginViewModel> with $LoginView {
  const LoginView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Container(
        decoration: VioletteTheme.gradientBackground,
        child: SparkleBackground(
          sparkleCount: 25,
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                // ConstrainedBox permet d'imposer des contraintes de hauteur et largeur
                constraints: BoxConstraints(
                  // minHeight définit la hauteur MINIMALE que doit occuper l'enfant. L'objectif ici : faire en sorte que le contenu occupe AU MOINS la hauteur totale disponible à l'écran.
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context)
                          .padding
                          .top // Représente l'espace que l'application de doit pas recouvrir en haut et en bas (bar de status et de navigation
                      -
                      MediaQuery.of(context).padding.bottom, //
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      const LoginHeader(),
                      const SizedBox(height: 48),
                      LoginForm(
                        emailController: emailController,
                        passwordController: passwordController,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
