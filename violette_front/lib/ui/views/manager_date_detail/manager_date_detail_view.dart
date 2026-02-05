import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/_widgets/manager_date_detail_content.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';

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
        title: Text(showDate.title),
      ),
      body: ManagerDateDetailContent(
        showDate: showDate,
        viewModel: viewModel,
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
