import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/ui/views/availability_choice/widgets/artist_show_date_card.dart';
import 'package:violette_front/ui/widgets/common/calendar/violette_calendar.dart';
import 'package:violette_front/ui/widgets/common/gradient_background/gradient_background.dart';
import 'availability_choice_viewmodel.dart';

class AvailabilityChoiceView extends StackedView<AvailabilityChoiceViewModel> {
  const AvailabilityChoiceView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AvailabilityChoiceViewModel viewModel,
    Widget? child,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await viewModel.onBackPressed();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Retour',
            onPressed: () async => viewModel.onBackPressed(),
          ),
          title: Semantics(
            header: true,
            child: const Text('Planning Artiste'),
          ),
        ),
        body: GradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    VioletteCalendar(
                      focusedDay: viewModel.focusedDay,
                      selectedDayPredicate: viewModel.isSelectedDay,
                      onDaySelected: viewModel.onDaySelected,
                      onPageChanged: viewModel.onPageChange,
                      dayColorBuilder: viewModel.getColorForDay,
                      dayStatusLabelBuilder: viewModel.getStatusLabelForDay,
                    ),
                    if (viewModel.selectedShowDates.isNotEmpty) ...[
                      for (final sd in viewModel.selectedShowDates)
                        ArtistShowDateCard(
                          showDate: sd,
                          availabilityStatus:
                              viewModel.getStatusForShowDateId(sd.id) ??
                                  AvailabilityStatus.pending,
                          bookingStatus:
                              viewModel.getBookingStatusForShowDate(sd.id),
                          isAvailabilityLocked:
                              viewModel.isShowDateConfirmedByBooking(sd.id),
                          availabilityLockMessage:
                              viewModel.confirmedBookingLockMessage,
                          onEditAvailability: () =>
                              viewModel.cycleAvailabilityForShowDate(sd),
                        ),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () async {
                          await viewModel.onValidatePressed();
                        },
                        child: viewModel.isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Terminé'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  AvailabilityChoiceViewModel viewModelBuilder(BuildContext context) =>
      AvailabilityChoiceViewModel();

  @override
  void onViewModelReady(AvailabilityChoiceViewModel viewModel) {
    viewModel.loadShowDates();
  }
}
