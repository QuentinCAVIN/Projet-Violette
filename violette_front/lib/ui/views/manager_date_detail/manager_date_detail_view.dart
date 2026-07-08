import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/manager_date_detail_body.dart';
import 'package:violette_front/ui/widgets/common/gradient_background/gradient_background.dart';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(viewModel.displayedShowDate.title),
      ),
      body: const GradientBackground(
        child: SafeArea(
          child: ManagerDateDetailBody(),
        ),
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
