import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/booking_status_pill.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/show_date_status_pill.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';
import 'package:violette_front/ui/widgets/common/availability_status_pill.dart';

class ManagerDateDetailBody extends ViewModelWidget<ManagerDateDetailViewModel> {
  final bool isInline;

  const ManagerDateDetailBody({
    super.key,
    this.isInline = false,
  });

  @override
  Widget build(BuildContext context, ManagerDateDetailViewModel viewModel) {
    final theme = Theme.of(context);
    final currentShowDate = viewModel.displayedShowDate;
    final availableNextStatuses = viewModel.getAvailableNextStatuses();
    final selectionLabel = currentShowDate.totalRequiredArtists > 0
        ? "Sélection : ${currentShowDate.selectedCount} / ${currentShowDate.totalRequiredArtists}"
        : "Sélection libre";

    final listView = ListView.builder(
      shrinkWrap: isInline,
      physics: isInline ? const NeverScrollableScrollPhysics() : null,
      itemCount: viewModel.artistLines.length,
      itemBuilder: (context, index) {
        final line = viewModel.artistLines[index];
        final artist = line.user;
        final apiArtistId = line.apiArtistId;

        final booking = viewModel.getBookingForArtist(apiArtistId);

        final isEnabled =
            viewModel.isSelectionEnabled(currentShowDate, apiArtistId);

        final availability = viewModel.getAvailabilityForArtist(apiArtistId);

        return Opacity(
          opacity: isEnabled ? 1 : 0.72,
          child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          color: theme.cardColor,
          child: ListTile(
            leading: SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: viewModel.isBookingCheckboxChecked(booking),
                onChanged: isEnabled
                    ? (val) => viewModel.toggleSelection(
                          apiArtistId,
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  artist.email,
                  style: theme.textTheme.bodyMedium,
                ),
                if (booking != null) ...[
                  const SizedBox(height: 4),
                  BookingStatusPill(
                    status: booking.status,
                  ),
                ] else if (availability != null) ...[
                  const SizedBox(height: 4),
                  AvailabilityStatusPill(
                    status: availability,
                  ),
                ],
                if (!isEnabled)
                  Text(
                    "Sélection indisponible",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            trailing: viewModel.canCancelBooking(booking)
                ? PopupMenuButton<String>(
                    tooltip: 'Actions',
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'cancel') {
                        viewModel.cancelBooking(apiArtistId);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'cancel',
                        child: Text(
                          'Annuler la réservation',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ));
      },
    );

    final reserveArtistsButton = Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: viewModel.canSendConfirmation
              ? viewModel.sendConfirmation
              : null,
          child: const Text('Réserver les artistes'),
        ),
      ),
    );

    final children = <Widget>[
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ShowDateStatusPill(status: currentShowDate.status),
            ),
            const SizedBox(height: 8),
            Text(
              selectionLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            // Le design actuel suppose une seule transition possible par statut ;
            // si plusieurs transitions coexistent un jour, remplacer ce bouton unique
            // par un sélecteur (menu ou boutons multiples).
            if (availableNextStatuses.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => viewModel.changeShowDateStatus(
                    availableNextStatuses.first,
                  ),
                  child: Text(
                    _statusTransitionActionLabel(availableNextStatuses.first),
                  ),
                ),
              ),
            ],
            if (viewModel.canCancelShowDate) ...[
              if (availableNextStatuses.isNotEmpty) const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: viewModel.cancelShowDate,
                  icon: Icon(
                    Icons.event_busy,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Annuler la date',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      if (viewModel.isBusy)
        if (isInline)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
      else ...[
        if (isInline)
          listView
        else
          Expanded(child: listView),
        reserveArtistsButton,
      ],
    ];

    return Column(
      mainAxisSize: isInline ? MainAxisSize.min : MainAxisSize.max,
      children: children,
    );
  }
}

/// Libellé du bouton d'action pour une transition de statut cible.
String _statusTransitionActionLabel(ShowDateStatus target) {
  switch (target) {
    case ShowDateStatus.option:
      return 'Passer en option';
    case ShowDateStatus.confirmed:
      return 'Confirmer la date';
    case ShowDateStatus.staffed:
      return 'Marquer l\'équipe complète';
    default:
      return 'Passer en ${target.label}';
  }
}
