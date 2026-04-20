import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../create_show_date_viewmodel.dart';
import '../create_show_date_view.form.dart';

class ShowDateForm extends ViewModelWidget<CreateShowDateViewModel> {
  final TextEditingController titleController;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController addressController;
  final TextEditingController artistsCountController;
  final TextEditingController descriptionController;

  const ShowDateForm({
    super.key,
    required this.titleController,
    required this.dateController,
    required this.startTimeController,
    required this.addressController,
    required this.artistsCountController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context, CreateShowDateViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Créer une préstation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 24),

        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Nom du spectacle',
            errorText: viewModel.titleValidationMessage,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Date',
            hintText: 'jj/mm/aaaa',
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: viewModel.dateValidationMessage,
          ),
          onTap: () => _selectDate(context, viewModel),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: startTimeController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Heure de convocation',
            hintText: '--:--',
            suffixIcon: const Icon(Icons.access_time),
            errorText: viewModel.startTimeValidationMessage,
          ),
          onTap: () => _selectTime(
            context: context,
            initialTime: viewModel.selectedStartTime,
            controller: startTimeController,
            onTimeChanged: viewModel.onStartTimeChanged,
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: 'Adresse / lieu',
            errorText: viewModel.addressValidationMessage,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: viewModel.clientContactNameController,
          decoration: InputDecoration(
            labelText: 'Nom du contact client',
            hintText: 'Ex : Marie Dupont',
            errorText: viewModel.clientContactNameError,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: viewModel.clientContactPhoneController,
          decoration: InputDecoration(
            labelText: 'Téléphone du contact client',
            hintText: 'Ex : 06 01 02 03 04',
            errorText: viewModel.clientContactPhoneError,
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: artistsCountController,
          decoration: InputDecoration(
            labelText: 'Artistes nécessaires',
            hintText: '5',
            errorText: viewModel.artistsCountValidationMessage,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText:
                'Décrivez le spectacle, le style recherché, les détails pratiques…',
            errorText: viewModel.descriptionValidationMessage,
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.isBusy ? null : viewModel.submitShowDateForm,
            child: viewModel.isBusy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Créer la date'),
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: viewModel.navigateBack,
            child: const Text('Annuler'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    CreateShowDateViewModel viewModel,
  ) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );

    if (picked == null) return;

    dateController.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';

    viewModel.onDateChanged(picked);
  }

  Future<void> _selectTime({
    required BuildContext context,
    required TimeOfDay? initialTime,
    required TextEditingController controller,
    required void Function(TimeOfDay) onTimeChanged,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );

    if (picked == null) return;

    controller.text = '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';

    onTimeChanged(picked);
  }
}
