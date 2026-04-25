import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/manager_date_detail_body.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.displayedShowDate.title),
        actions: [
          if (viewModel.getAvailableNextStatuses().isNotEmpty)
            PopupMenuButton<ShowDateStatus>(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Changer le statut',
              onSelected: viewModel.changeShowDateStatus,
              itemBuilder: (context) => viewModel
                  .getAvailableNextStatuses()
                  .map(
                    (status) => PopupMenuItem<ShowDateStatus>(
                      value: status,
                      child: Text('Passer en ${status.label}'),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      body: const ManagerDateDetailBody(),
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
