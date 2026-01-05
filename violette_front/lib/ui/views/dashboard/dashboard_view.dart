import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/views/dashboard/dashboard_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      viewModelBuilder: () => DashboardViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(viewModel.viewTitle),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              // Bouton pour simuler le changement de rôle
              IconButton(
                icon: const Icon(Icons.switch_account),
                tooltip: 'Changer de rôle',
                onPressed: viewModel.switchUserRole,
              ),
            ],
          ),
          // Affiche le tableau de bord approprié en fonction du rôle
          body: viewModel.currentUserRole == UserRole.artist
              ? const _ArtistDashboard()
              : const _ManagerDashboard(),
        );
      },
    );
  }
}

// --- Tableau de Bord pour l'Artiste ---
class _ArtistDashboard extends ViewModelWidget<DashboardViewModel> {
  const _ArtistDashboard({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, DashboardViewModel viewModel) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Propositions en attente',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...viewModel.artistPendingOffers.map((offer) => Card(
              child: ListTile(
                title: Text(offer),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            )),
        const SizedBox(height: 24),
        Text(
          'Mes prochaines dates',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        ...viewModel.artistUpcomingDates.map((date) => Card(
              color: theme.colorScheme.tertiary.withOpacity(0.3),
              child: ListTile(title: Text(date)),
            )),
      ],
    );
  }
}

// --- Tableau de Bord pour le Gérant ---
class _ManagerDashboard extends ViewModelWidget<DashboardViewModel> {
  const _ManagerDashboard({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, DashboardViewModel viewModel) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Actions requises',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          ...viewModel.managerDatesToFinalize.map((date) => Card(
                child: ListTile(
                  title: Text(date),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              )),
          const SizedBox(height: 24),
          Text(
            'Prochaines dates confirmées',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          ...viewModel.managerUpcomingDates.map((date) => Card(
                color: theme.colorScheme.tertiary.withOpacity(0.3),
                child: ListTile(title: Text(date)),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Naviguer vers l'écran de création de date
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
