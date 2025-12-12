import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/app_theme.dart';

import 'login_header_model.dart';

class LoginHeader extends StackedView<LoginHeaderModel> {
  const LoginHeader({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginHeaderModel viewModel,
    Widget? child,
  ) {
    return Column(
      children: [
        // Logo container avec image
        Container(
          width: 100,
          height: 100,
          decoration: VioletteTheme.logoContainer,
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Texte "Violette"
        Text(
          'Violette',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(),
        ),
      ],
    );
  }

  @override
  LoginHeaderModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginHeaderModel();
}
