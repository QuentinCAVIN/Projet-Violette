import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/enums/booking_status.dart';
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

    final listView = ListView.builder(
      shrinkWrap: isInline,
      physics: isInline ? const NeverScrollableScrollPhysics() : null,
      itemCount: viewModel.availableArtists.length,
      itemBuilder: (context, index) {
        final artist = viewModel.availableArtists[index];

        final booking = viewModel.getBookingForArtist(artist.uid);

        final isSelected = booking?.status == BookingStatus.selected;

        final isEnabled =
            viewModel.isSelectionEnabled(currentShowDate, artist.uid);

        final availability = viewModel.getAvailabilityForArtist(artist.uid);

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
    );

    final children = <Widget>[
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
            ElevatedButton(
              onPressed: viewModel.canSendConfirmation
                  ? viewModel.sendConfirmation
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 36),
              ),
              child: const Text("Demander confirmation"),
            ),
          ],
        ),
      ),
      if (viewModel.isBusy)
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
      children: children,
    );
  }
}
