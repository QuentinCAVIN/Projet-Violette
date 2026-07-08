import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/common/ui_helpers.dart';
import 'package:violette_front/ui/widgets/common/gradient_background/gradient_background.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    // Erreur réseau ou backend inaccessible au démarrage.
    if (viewModel.startupError != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: GradientBackground(
          decoration: VioletteTheme.authGradientBackground,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: VioletteTheme.textPrimary.withValues(alpha: 0.85),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Serveur inaccessible',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: VioletteTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.startupError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: VioletteTheme.textPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: viewModel.runStartupLogic,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                      OutlinedButton.icon(
                        onPressed: viewModel.logoutAndGoToLogin,
                        icon: const Icon(Icons.logout),
                        label: const Text('Se déconnecter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        decoration: VioletteTheme.authGradientBackground,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VIOLETTE',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: VioletteTheme.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chargement...',
                    style: TextStyle(
                      fontSize: 16,
                      color: VioletteTheme.textPrimary,
                    ),
                  ),
                  horizontalSpaceSmall,
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: VioletteTheme.textPrimary,
                      strokeWidth: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}
