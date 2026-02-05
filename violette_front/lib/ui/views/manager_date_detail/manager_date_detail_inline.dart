import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/manager_date_detail_body.dart';

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
    return const Card(
      margin: EdgeInsets.only(top: 8),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ManagerDateDetailBody(
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
