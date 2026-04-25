import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/booking_status_pill.dart';
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
        : "Sélection libre : besoins artistes non configurés";

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

        return Card(
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
            subtitle: Text(
              artist.email,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO(v0.5.0): distinguer plus explicitement en UI
                // "disponible", "préselectionné" et "confirmé" côté manager.
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
    );

    final children = <Widget>[
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectionLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isInline && availableNextStatuses.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<ShowDateStatus>(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Changer le statut',
                    onSelected: viewModel.changeShowDateStatus,
                    itemBuilder: (context) => availableNextStatuses
                        .map(
                          (status) => PopupMenuItem<ShowDateStatus>(
                            value: status,
                            child: Text('Passer en ${status.label}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: viewModel.canSendConfirmation
                    ? viewModel.sendConfirmation
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  "Demander confirmation",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
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
      else if (isInline)
        listView
      else
        Expanded(child: listView),
    ];

    return Column(
      mainAxisSize: isInline ? MainAxisSize.min : MainAxisSize.max,
      children: children,
    );
  }
}
