import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/_widgets/manager_date_detail_content.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';

class ManagerDateDetailInline extends StackedView<ManagerDateDetailViewModel> {
  final ShowDate showDate;

  const ManagerDateDetailInline({
    super.key,
    required this.showDate,
  });

  @override
  Widget builder(
    BuildContext context,
    ManagerDateDetailViewModel viewModel,
    Widget? child,
  ) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ManagerDateDetailContent(
          showDate: showDate,
          viewModel: viewModel,
          isInline: true,
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
