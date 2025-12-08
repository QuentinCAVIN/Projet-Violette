import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/app_colors.dart';
import 'package:violette_front/ui/common/ui_helpers.dart';

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
                    MaterialButton(
                      color: kcPrimaryColor,
                      onPressed: viewModel.navigateToAvailabilityChoiceView,
                      child: const Text(
                        'Dispos',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    MaterialButton(
                      color: kcPrimaryColor,
                      onPressed: viewModel.logOut,
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Text(
                      'G.O.A.T.!!',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    verticalSpaceMedium,
                    MaterialButton(
                      color: Colors.black,
                      onPressed: viewModel.incrementCounter,
                      child: Text(
                        viewModel.counterLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialButton(
                      color: kcDarkGreyColor,
                      onPressed: viewModel.showDialog,
                      child: const Text(
                        'Show Dialog',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    MaterialButton(
                      color: kcDarkGreyColor,
                      onPressed: viewModel.showBottomSheet,
                      child: const Text(
                        'Show Bottom Sheet',
                        style: TextStyle(color: Colors.white),
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
