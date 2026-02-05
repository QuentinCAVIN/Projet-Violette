import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/manager_date_detail_body.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';

class ManagerShowDateInlineDetail extends StatelessWidget {
  final ShowDate showDate;

  const ManagerShowDateInlineDetail({
    super.key,
    required this.showDate,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManagerDateDetailViewModel>.reactive(
      viewModelBuilder: () => ManagerDateDetailViewModel(showDate: showDate),
      onViewModelReady: (viewModel) => viewModel.initialize(),
      builder: (context, viewModel, child) {
        return const Card(
          margin: EdgeInsets.only(top: 8),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: ManagerDateDetailBody(
              isInline: true,
            ),
          ),
        );
      },
    );
  }
}
