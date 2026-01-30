import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/ui_helpers.dart';

import '../../../models/enums/role.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    final currentUser = viewModel.currentUser; //Pour test de récupération user

    // Pour gérer l'erreur du User null
    if (viewModel.isBusy) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // TODO -> A retirer probablement inutile?
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Utilisateur introuvable"),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                verticalSpaceLarge,
                Column(
                  children: [
                    //**********************************************************
                    //Insertion des infos du User dans la view de base pour test
                    Column(
                      children: [
                        Text(
                          "Bienvenue ${currentUser.firstName} ${currentUser.lastName}",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    //**********************************************************
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        title: Text(
                          // TODO rajouter de quoi afficher une liste de role et non pas le premier de la liste
                          "Profil : ${currentUser.roles[0].label} ",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                    ),

                    verticalSpaceMedium,

                    if (currentUser.roles.contains(Role.manager)) ...[
                      ElevatedButton(
                        onPressed: viewModel.navigateToShowDateFormView,
                        child: const Text(
                          'Créer une nouvelle date',
                        ),
                      ),
                      verticalSpaceMedium,
                      ElevatedButton(
                        onPressed: viewModel.navigateToManagerPlanningView,
                        child: const Text(
                          'Consulter le Planning',
                        ),
                      ),
                    ],
                    // Bouton navigation sélection des dispos visible par les artistes uniquement
                    if (currentUser.roles.contains(Role.artist))
                      ElevatedButton(
                        onPressed: viewModel.navigateToAvailabilityChoiceView,
                        child: const Text(
                          'Sélection des dispos',
                        ),
                      ),
                    verticalSpaceMassive,

                    ElevatedButton(
                      onPressed: viewModel.logOut,
                      child: const Text('Déconnexion'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: viewModel.showDialog,
                        child: const Text('Show Dialog'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: viewModel.showBottomSheet,
                        child: const Text('Show Bottom Sheet'),
                      ),
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

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  //TODO A virer quand j'aurais rendu le User accecible globalement
  @override
  void onViewModelReady(HomeViewModel viewModel) {
    viewModel.loadUser();
  }
}
