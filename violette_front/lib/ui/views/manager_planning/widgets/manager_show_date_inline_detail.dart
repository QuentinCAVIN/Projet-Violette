import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/views/manager_date_detail/widgets/manager_date_detail_body.dart';
import 'package:violette_front/ui/views/manager_date_detail/manager_date_detail_viewmodel.dart';

class ManagerShowDateInlineDetail extends StatelessWidget {
  final ShowDate showDate;
  final Future<void> Function(ShowDate updatedShowDate)? onShowDateUpdated;
  final VoidCallback? onOpenFullDetail;

  const ManagerShowDateInlineDetail({
    super.key,
    required this.showDate,
    this.onShowDateUpdated,
    this.onOpenFullDetail,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManagerDateDetailViewModel>.reactive(
      viewModelBuilder: () => ManagerDateDetailViewModel(
        showDate: showDate,
        onShowDateUpdated: onShowDateUpdated,
      ),
      onViewModelReady: (viewModel) => viewModel.initialize(),
      builder: (context, viewModel, child) {
        return Card(
          margin: const EdgeInsets.only(top: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ManagerDateDetailBody(
              isInline: true,
              onOpenFullDetail: onOpenFullDetail,
            ),
          ),
        );
      },
    );
  }
}
