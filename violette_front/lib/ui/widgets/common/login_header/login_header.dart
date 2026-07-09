import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/app_theme.dart';

import 'login_header_model.dart';

class LoginHeader extends StackedView<LoginHeaderModel> {
  const LoginHeader({super.key});

  static const double _logoSize = 200;

  @override
  Widget builder(
    BuildContext context,
    LoginHeaderModel viewModel,
    Widget? child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: _logoSize,
          height: _logoSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 28),
        Text(
          'VIOLETTE',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w300,
                letterSpacing: 6,
                color: VioletteTheme.textPrimary,
              ),
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
