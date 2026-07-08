import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'package:violette_front/ui/widgets/common/gradient_background/gradient_background.dart';

import 'widget/show_date_form.dart';
import 'create_show_date_view.form.dart';
import 'create_show_date_viewmodel.dart';

@FormView(
  fields: [
    FormTextField(name: 'title'),
    FormTextField(name: 'date'),
    FormTextField(name: 'startTime'),
    FormTextField(name: 'address'),
    FormTextField(name: 'description'),
  ],
)
class CreateShowDateView extends StackedView<CreateShowDateViewModel>
    with $CreateShowDateView {
  const CreateShowDateView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CreateShowDateViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Nouvelle date de spectacle'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ShowDateForm(
                  titleController: titleController,
                  dateController: dateController,
                  startTimeController: startTimeController,
                  addressController: addressController,
                  descriptionController: descriptionController,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(CreateShowDateViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(CreateShowDateViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }

  @override
  CreateShowDateViewModel viewModelBuilder(BuildContext context) =>
      CreateShowDateViewModel();
}
