import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';
import 'package:violette_front/ui/views/manager_date_detail/_widgets/booking_status_pill.dart';
import 'package:violette_front/ui/views/manager_planning/_widgets/availability_status_pill.dart';

/// Vue "Détail d’une date" côté gérant.
class ManagerDateDetailView extends StackedView<ManagerDateDetailViewModel> {
  final ShowDate showDate;

  const ManagerDateDetailView({
    super.key,
    required this.showDate,
  });

  @override
  Widget builder(
    BuildContext context,
    ManagerDateDetailViewModel viewModel,
    Widget? child,
  ) {
    // On récupère le thème pour un accès facile
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(showDate.title),
      ),
      body: StreamBuilder<ShowDate>(
        // Stream permettant de mettre à jour en temps réel
        // TODO Verifier si ça ne posde pas un probléme de latence
        // le compteur selectedCount / artistsCount
        stream: viewModel.showDateStream,
        builder: (context, snapshot) {
          // Fallback sur la date initiale tant que le stream n’a rien émis
          final currentShowDate = snapshot.data ?? showDate;

          return Column(
            children: [
              /// ============================
              /// HEADER – État de la sélection
              /// ============================
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Sélection : ${currentShowDate.selectedCount} / ${currentShowDate.artistsCount}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Bouton d’envoi des demandes de confirmation
                    // Activé uniquement s’il reste au moins un artiste en status "selected"
                    // TODO: voir avec Elodie si on change ce comportememnt (envoi d'invitation sans tenir compte du nbr d'artiste necessaire sur la date)
                    ElevatedButton(
                      onPressed: viewModel.canSendConfirmation
                          ? viewModel.sendConfirmation
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                            120, 36), // Avoid infinite width from global theme
                      ),
                      child: const Text("Demander confirmation"),
                    ),
                  ],
                ),
              ),

              /// ============================
              /// LISTE DES ARTISTES
              /// ============================
              Expanded(
                child: viewModel.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: viewModel.availableArtists.length,
                        itemBuilder: (context, index) {
                          final artist = viewModel.availableArtists[index];

                          final booking =
                              viewModel.getBookingForArtist(artist.uid);

                          // L’artiste est considéré comme sélectionné
                          // uniquement si son booking est en status "selected"
                          final isSelected =
                              booking?.status == BookingStatus.selected;

                          // Détermine si la checkbox est activable
                          final isEnabled =
                              viewModel.isSelectionEnabled(artist.uid);

                          final availability =
                              currentShowDate.artistsAvailability[artist.uid];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: theme.cardColor,
                            child: ListTile(
                              /// Checkbox de sélection
                              leading: SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: isSelected || booking != null,
                                  onChanged: isEnabled
                                      ? (val) => viewModel.toggleSelection(
                                            artist.uid,
                                            val ?? false,
                                          )
                                      : null,
                                  activeColor: theme.colorScheme.primary,
                                  checkColor: theme.colorScheme.onPrimary,
                                ),
                              ),

                              title: Text(
                                "${artist.firstName} ${artist.lastName}",
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                artist.email,
                                style: theme.textTheme.bodyMedium,
                              ),

                              // TODO les deux se chevauchent pour le moment, etudier un refactor
                              /// Indicateur visuel à droite :
                              /// - BookingStatusPill si un booking existe
                              /// - Sinon AvailabilityStatusPill
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (booking != null)
                                    BookingStatusPill(
                                      status: booking.status,
                                    )
                                  else if (availability != null)
                                    AvailabilityStatusPill(
                                      status: availability,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  ManagerDateDetailViewModel viewModelBuilder(BuildContext context) =>
      ManagerDateDetailViewModel(showDate: showDate);

  @override
  void onViewModelReady(ManagerDateDetailViewModel viewModel) {
    viewModel.initialize();
  }
}
