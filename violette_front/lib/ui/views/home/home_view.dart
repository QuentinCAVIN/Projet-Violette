import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/common/ui_helpers.dart';
import 'package:violette_front/ui/widgets/common/gradient_background/gradient_background.dart';

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
        backgroundColor: Colors.transparent,
        body: GradientBackground(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // currentUser == null sans isBusy signifie que loadUser() a déclenché une
    // navigation (logout + LoginView). La view sera détruite immédiatement ;
    // ce fallback n'est jamais visible en pratique.
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: GradientBackground(
          child: Center(
            child: Text("Utilisateur introuvable"),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
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
                    final showDate = viewModel.requestsShowDates[dateId];

                    return BookingRequestCard(
                      booking: booking,
                      showDate: showDate,
                      isBusy: viewModel.isBusy ||
                          viewModel.isRespondingToBookingRequest,
                      onAccept: () => viewModel.respondToRequest(booking, true),
                      onRefuse: () => viewModel.respondToRequest(booking, false),
                    );
                  }),
                  verticalSpaceMedium,
                ],

                // ZONE 1 — EN-TÊTE D'IDENTITÉ
                Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    container: true,
                    label:
                        "Bienvenue ${currentUser.firstName} ${currentUser.lastName}, profil ${currentUser.roles[0].label}",
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bienvenue ${currentUser.firstName} ${currentUser.lastName}",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              // DETTE-12 : afficher tous les rôles de l'utilisateur, pas seulement le premier
                              "Profil : ${currentUser.roles[0].label}",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ZONE 2 — ACTIONS (centrées dans l'espace flexible)
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentUser.roles.contains(Role.manager)) ...[
                            _HomeActionCard(
                              icon: Icons.event_available,
                              title: "Créer une nouvelle date",
                              subtitle: "Planifier un spectacle",
                              onTap: viewModel.navigateToShowDateFormView,
                              backgroundColor: VioletteTheme.buttonPrimary,
                            ),
                            const SizedBox(height: 14),
                            _HomeActionCard(
                              icon: Icons.calendar_today,
                              title: "Consulter le planning",
                              subtitle: "Voir toutes les dates",
                              onTap: viewModel.navigateToManagerPlanningView,
                              backgroundColor: Colors.white.withValues(alpha: 0.10),
                              borderColor: Colors.white.withValues(alpha: 0.25),
                            ),
                          ],
                          if (currentUser.roles.contains(Role.artist))
                            _HomeActionCard(
                              icon: Icons.event,
                              title: "Planning Artiste",
                              subtitle: "Gérer mes disponibilités",
                              onTap: viewModel.navigateToAvailabilityChoiceView,
                              backgroundColor: VioletteTheme.buttonPrimary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ZONE 3 — DÉCONNEXION ANCRÉE EN BAS
                Container(
                  height: 0.5,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: viewModel.logOut,
                    icon: Icon(
                      Icons.logout,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                    label: Text(
                      "Déconnexion",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
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

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color? borderColor;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: borderColor == null ? null : Border.all(color: borderColor!),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 24, color: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
