import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '_widgets/availability_calendar.dart';
import 'availability_choice_viewmodel.dart';

class AvailabilityChoiceView extends StackedView<AvailabilityChoiceViewModel> {
  const AvailabilityChoiceView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AvailabilityChoiceViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection des dates'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child:
        const Center(
            child: AvailabilityCalendar(),
        ),
      ),
    );
  }

  @override
  AvailabilityChoiceViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AvailabilityChoiceViewModel();
}
