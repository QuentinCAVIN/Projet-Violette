import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_form_model.dart';

class LoginForm extends StackedView<LoginFormModel> {
  const LoginForm({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginFormModel viewModel,
    Widget? child,
  ) {
    return const Placeholder(child: Text("Login Form"));
  }

  @override
  LoginFormModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginFormModel();
}
