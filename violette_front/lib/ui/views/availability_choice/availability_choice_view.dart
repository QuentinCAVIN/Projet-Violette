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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            children: [
              const AvailabilityCalendar(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await viewModel.onValidatePressed();
                  },
                  child: viewModel.isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Valider"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  AvailabilityChoiceViewModel viewModelBuilder(BuildContext context) =>
      AvailabilityChoiceViewModel();

  @override
  void onViewModelReady(AvailabilityChoiceViewModel viewModel) {
    viewModel.loadShowDates();
  }
}
