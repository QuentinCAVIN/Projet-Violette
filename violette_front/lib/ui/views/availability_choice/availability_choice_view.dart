import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/ui/widgets/common/show_date_detail/show_date_detail.dart';
import 'package:violette_front/ui/widgets/common/calendar/violette_calendar.dart';
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Retour',
            onPressed: () async => viewModel.onBackPressed(),
          ),
          title: const Text('Sélection des dates'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
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
                  for (final sd in viewModel.selectedShowDates) ...[
                    ShowDateDetail(
                      showDate: sd,
                      status: viewModel.getStatusForShowDateId(sd.id) ??
                          AvailabilityStatus.pending,
                    ),
                    if (viewModel.isShowDateConfirmedByBooking(sd.id))
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.lock,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(viewModel.confirmedBookingLockMessage),
                        ),
                      ),
                    if (viewModel.selectedShowDates.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            onPressed: viewModel.isBusy ||
                                    viewModel.isShowDateConfirmedByBooking(sd.id)
                                ? null
                                : () => viewModel.cycleAvailabilityForShowDate(sd),
                            child: Text(
                              viewModel.isShowDateConfirmedByBooking(sd.id)
                                  ? 'Disponibilité verrouillée'
                                  : 'Mettre à jour ma disponibilité',
                            ),
                          ),
                        ),
                      ),
                  ],
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
                        : const Text("Valider"),
                  ),
                ),
              ],
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
