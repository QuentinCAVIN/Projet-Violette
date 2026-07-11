import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/ui/views/manager_planning/widgets/manager_show_date_inline_detail.dart';
import 'package:violette_front/ui/views/manager_planning/widgets/manager_show_date_summary_card.dart';
import 'package:violette_front/ui/widgets/common/calendar/violette_calendar.dart';
import 'package:violette_front/ui/widgets/common/gradient_background/gradient_background.dart';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Planning Gérant'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                    dayStatusLabelBuilder: viewModel.getStatusLabelForDay,
                  ),
                  if (viewModel.isBusy)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                  if (viewModel.selectedShowDates.isNotEmpty)
                    Column(
                      children: [
                        for (final selectedShowDate
                            in viewModel.selectedShowDates) ...[
                          ManagerShowDateSummaryCard(
                            showDate: selectedShowDate,
                            onTap: () =>
                                viewModel.toggleExpanded(selectedShowDate),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: viewModel.isExpanded(selectedShowDate)
                                ? ManagerShowDateInlineDetail(
                                    showDate: selectedShowDate,
                                    onShowDateUpdated: viewModel
                                        .refreshShowDateAfterStatusChange,
                                    onOpenFullDetail: () => viewModel
                                        .navigateToDetail(selectedShowDate),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  if (viewModel.selectedDay != null &&
                      viewModel.selectedShowDates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("Aucune date prévue ce jour."),
                    ),
                ],
              ),
            ),
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
