import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_header_model.dart';

class LoginHeader extends StackedView<LoginHeaderModel> {
  const LoginHeader({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginHeaderModel viewModel,
    Widget? child,
  ) {
    return const SizedBox.shrink();
  }

  @override
  LoginHeaderModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginHeaderModel();
}
