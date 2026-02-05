import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/views/manager_planning/_widgets/manager_date_detail_card.dart';
import 'package:violette_front/ui/widgets/common/calendar/violette_calendar.dart';

import 'manager_planning_viewmodel.dart';


class ManagerPlanningView extends StackedView<ManagerPlanningViewModel> {
  const ManagerPlanningView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ManagerPlanningViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning Gérant'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              VioletteCalendar(
                focusedDay: viewModel.focusedDay,
                selectedDayPredicate: viewModel.isSelectedDay,
                onDaySelected: viewModel.onDaySelected,
                onPageChanged: viewModel.onPageChange,
                // On peut colorer les jours selon leur statut global
                dayColorBuilder: viewModel.getColorForDay,
              ),
              if (viewModel.isBusy)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                ),
              if (viewModel.showDatePicked != null)
                GestureDetector(
                  onTap: () => viewModel.navigateToDetail(viewModel.showDatePicked!),
                  child: ManagerDateDetailCard(
                      showDate: viewModel.showDatePicked!),
                ),
              if (viewModel.selectedDay != null &&
                  viewModel.showDatePicked == null)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("Aucune date prévue ce jour."),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  ManagerPlanningViewModel viewModelBuilder(BuildContext context) =>
      ManagerPlanningViewModel();

  @override
  void onViewModelReady(ManagerPlanningViewModel viewModel) {
    viewModel.loadShowDates();
  }
}
