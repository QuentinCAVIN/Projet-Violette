import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/ui_helpers.dart';

import '../../../models/enums/role.dart';
import 'home_viewmodel.dart';
import 'package:violette_front/ui/widgets/booking_request_card.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    final currentUser = viewModel.currentUser;

    // Pour gérer l'erreur du User null
    if (viewModel.isBusy) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // currentUser == null sans isBusy signifie que loadUser() a déclenché une
    // navigation (logout + LoginView). La view sera détruite immédiatement ;
    // ce fallback n'est jamais visible en pratique.
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  verticalSpaceLarge,
                  // SECTION : DEMANDES EN ATTENTE
                    if (viewModel.pendingRequests.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Demandes en attente",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...viewModel.pendingRequests.map((booking) {
                        final dateId = booking.dateId;
                        if (dateId == null || dateId.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final showDate =
                            viewModel.requestsShowDates[dateId];

                        return BookingRequestCard(
                          booking: booking,
                          showDate: showDate,
                          isBusy: viewModel.isBusy ||
                              viewModel.isRespondingToBookingRequest,
                          onAccept: () =>
                              viewModel.respondToRequest(booking, true),
                          onRefuse: () =>
                              viewModel.respondToRequest(booking, false),
                        );
                      }),
                      verticalSpaceMedium,
                    ],

                    // SECTION : PROFIL
                    Column(
                      children: [
                        Text(
                          "Bienvenue ${currentUser.firstName} ${currentUser.lastName}",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
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
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: viewModel.navigateToAvailabilityChoiceView,
                        child: const Text(
                          'Sélection des dispos',
                        ),
                      ),
                    verticalSpaceMassive,

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: viewModel.logOut,
                      child: const Text('Déconnexion'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    viewModel.loadUser();
  }
}
