import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/ui_helpers.dart';

import '../../../models/enums/role.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    final currentUser = viewModel.currentUser; //Pour test de récupération user

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
                        if (viewModel.isBusy)
                          const CircularProgressIndicator()
                        else if (currentUser == null)
                          const Text("Utilisateur introuvable")
                        else
                          Text(
                            "Bienvenue ${currentUser.firstName} ${currentUser.lastName}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    //**********************************************************
                    const SizedBox(height: 16),

                    // Bouton navigation creation date
                    if (currentUser!.roles.contains(Role.manager))
                    ElevatedButton(
                      onPressed: viewModel.navigateToShowDateFormView,
                      child: const Text(
                        'Créer une nouvelle date (vue gérant)',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bouton navigation sélection des dispos
                    if (currentUser.roles.contains(Role.artist))
                    ElevatedButton(
                      onPressed: viewModel.navigateToAvailabilityChoiceView,
                      child: const Text(
                        'Sélection des dispos (vue artiste)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: viewModel.logOut,
                      child: const Text('Déconnexion'),
                    ),
                    const SizedBox(height: 24),
                     Text(
                       // TODO rajouter de quoi afficher une liste de role et non pas le premier de la liste
                      "Grade : ${currentUser.roles[0].label} " ,
                       style: Theme.of(context).textTheme.displayLarge?.copyWith(
                         letterSpacing: 1.2,
                       ),
                    ),
                    verticalSpaceMedium,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: viewModel.incrementCounter,
                      child: Text(viewModel.counterLabel),
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
