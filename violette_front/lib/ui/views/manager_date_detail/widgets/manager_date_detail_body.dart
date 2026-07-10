import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/booking_status_pill.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/show_date_status_pill.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';
import 'package:violette_front/ui/widgets/common/availability_status_pill.dart';

/// Rouge clair lisible sur fond dégradé sombre (bouton tertiaire).
const _cancelActionColor = Color(0xFFF0997B);

class ManagerDateDetailBody
    extends ViewModelWidget<ManagerDateDetailViewModel> {
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
    final horizontalMargin = isInline ? 0.0 : 16.0;

    final listView = ListView.builder(
      shrinkWrap: isInline,
      physics: isInline ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.zero,
      itemCount: viewModel.artistLines.length,
      itemBuilder: (context, index) {
        final line = viewModel.artistLines[index];
        final artist = line.user;
        final apiArtistId = line.apiArtistId;

        final booking = viewModel.getBookingForArtist(apiArtistId);

        final isEnabled =
            viewModel.isSelectionEnabled(currentShowDate, apiArtistId);

        final availability = viewModel.getAvailabilityForArtist(apiArtistId);
        final isChecked = viewModel.isBookingCheckboxChecked(booking);
        final artistName = '${artist.firstName} ${artist.lastName}';

        return Semantics(
          container: true,
          label: _artistLineAccessibilityLabel(
            artistName: artistName,
            booking: booking,
            availability: availability,
            isChecked: isChecked,
            isEnabled: isEnabled,
          ),
          checked: isChecked,
          enabled: isEnabled,
          onTap: isEnabled
              ? () => viewModel.toggleSelection(
                    apiArtistId,
                    !isChecked,
                  )
              : null,
          child: Opacity(
            opacity: isEnabled ? 1 : 0.72,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: Checkbox(
                      value: isChecked,
                      onChanged: isEnabled
                          ? (val) => viewModel.toggleSelection(
                                apiArtistId,
                                val ?? false,
                              )
                          : null,
                      activeColor: theme.colorScheme.primary,
                      checkColor: theme.colorScheme.onPrimary,
                      // Bordure visible a l'etat decoche : la carte a un fond blanc,
                      // sans quoi la case decochee disparait (BOGUE-02).
                      side: const BorderSide(
                        color: VioletteTheme.textOnCardSecondary,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: VioletteTheme.textOnCard,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artist.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: VioletteTheme.textOnCardSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (!isEnabled) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'Sélection indisponible',
                              style: TextStyle(
                                color: VioletteTheme.textOnCardSecondary,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    fit: FlexFit.loose,
                    child: ExcludeSemantics(
                      child: _buildStatusPill(
                        booking: booking,
                        availability: availability,
                      ),
                    ),
                  ),
                  if (viewModel.canCancelBooking(booking))
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      tooltip: 'Actions',
                      icon: const Icon(
                        Icons.more_vert,
                        color: VioletteTheme.textOnCardSecondary,
                      ),
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
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final headerSection = Column(
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
          style: const TextStyle(
            color: VioletteTheme.cardTitle,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final lavenderCardDecoration = BoxDecoration(
      color: VioletteTheme.cardSurface,
      borderRadius: BorderRadius.circular(16),
    );

    final lavenderCardMargin =
        EdgeInsets.symmetric(horizontal: horizontalMargin);

    final actionsBlock = Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin + 16,
        16,
        horizontalMargin + 16,
        16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Le design actuel suppose une seule transition possible par statut ;
          // si plusieurs transitions coexistent un jour, remplacer ce bouton unique
          // par un sélecteur (menu ou boutons multiples).
          if (availableNextStatuses.isNotEmpty) ...[
            ElevatedButton(
              onPressed: () => viewModel.changeShowDateStatus(
                availableNextStatuses.first,
              ),
              child: Text(
                _statusTransitionActionLabel(availableNextStatuses.first),
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: VioletteTheme.textPrimary,
              disabledForegroundColor:
                  VioletteTheme.textPrimary.withValues(alpha: 0.5),
              side: BorderSide(
                color: viewModel.canSendConfirmation
                    ? VioletteTheme.textPrimary
                    : VioletteTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
            onPressed: viewModel.canSendConfirmation
                ? viewModel.sendConfirmation
                : null,
            child: const Text('Réserver les artistes'),
          ),
          if (viewModel.canCancelShowDate) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: viewModel.cancelShowDate,
                icon: const Icon(
                  Icons.event_busy,
                  color: _cancelActionColor,
                ),
                label: const Text(
                  'Annuler la date',
                  style: TextStyle(color: _cancelActionColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (viewModel.isBusy) {
      return Column(
        mainAxisSize: isInline ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            margin: lavenderCardMargin,
            padding: const EdgeInsets.all(16),
            decoration: lavenderCardDecoration,
            child: headerSection,
          ),
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
            ),
        ],
      );
    }

    if (isInline) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            margin: lavenderCardMargin,
            padding: const EdgeInsets.all(16),
            decoration: lavenderCardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerSection,
                const SizedBox(height: 12),
                listView,
              ],
            ),
          ),
          actionsBlock,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            margin: lavenderCardMargin,
            padding: const EdgeInsets.all(16),
            decoration: lavenderCardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerSection,
                const SizedBox(height: 12),
                Expanded(child: listView),
              ],
            ),
          ),
        ),
        actionsBlock,
      ],
    );
  }

  Widget _buildStatusPill({
    required ArtistBooking? booking,
    required AvailabilityStatus? availability,
  }) {
    if (booking != null) {
      return BookingStatusPill(status: booking.status);
    }
    if (availability != null) {
      return AvailabilityStatusPill(status: availability);
    }
    return const SizedBox.shrink();
  }
}

/// Libellé d'accessibilité regroupé pour une ligne artiste du détail gérant.
String _artistLineAccessibilityLabel({
  required String artistName,
  required ArtistBooking? booking,
  required AvailabilityStatus? availability,
  required bool isChecked,
  required bool isEnabled,
}) {
  final buffer = StringBuffer(artistName);

  if (booking != null) {
    buffer.write(', engagement : ${booking.status.displayName}');
  } else if (availability != null) {
    buffer.write(', disponibilité : ${availability.label}');
  }

  buffer.write(isChecked ? ', sélectionnée' : ', non sélectionnée');

  if (!isEnabled) {
    buffer.write(', sélection indisponible');
  }

  return buffer.toString();
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
