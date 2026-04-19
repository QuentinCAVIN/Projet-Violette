import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../create_show_date_viewmodel.dart';
import '../create_show_date_view.form.dart';

class ShowDateForm extends ViewModelWidget<CreateShowDateViewModel> {
  final TextEditingController titleController;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController addressController;
  final TextEditingController artistsCountController;
  final TextEditingController feeController;
  final TextEditingController descriptionController;

  const ShowDateForm({
    super.key,
    required this.titleController,
    required this.dateController,
    required this.startTimeController,
    required this.addressController,
    required this.endTimeController,
    required this.artistsCountController,
    required this.feeController,
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

        // Nom du spectacle
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Nom du spectacle',
            errorText: viewModel.titleValidationMessage,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Date (picker)
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

        // Heure début / fin (pickers)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: startTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Heure début',
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: endTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Heure fin',
                  hintText: '--:--',
                  suffixIcon: const Icon(Icons.access_time),
                  errorText: viewModel.endTimeValidationMessage,
                ),
                onTap: () => _selectTime(
                  context: context,
                  initialTime: viewModel.selectedEndTime,
                  controller: endTimeController,
                  onTimeChanged: viewModel.onEndTimeChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Adresse / lieu
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: 'Adresse / lieu',
            errorText: viewModel.addressValidationMessage,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Contact client — nom
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

        // Contact client — téléphone
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

        // Artistes nécessaires / Rémunération
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: artistsCountController,
                decoration: InputDecoration(
                  labelText: 'Artistes nécessaires',
                  hintText: '5',
                  errorText: viewModel.artistsCountValidationMessage,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: feeController,
                decoration: InputDecoration(
                  labelText: 'Rémunération (€)',
                  hintText: '150',
                  errorText: viewModel.feeValidationMessage,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
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

        // Message d'erreur global
        if (viewModel.globalErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              viewModel.globalErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),

        // Bouton "Créer la date"
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

        // Bouton "Annuler"
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

  //TODO A Refactoriser dans une method DateUtil
//****************************************************************************//
//DATE ET TIME PICKERS                                                        //
//****************************************************************************//
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

    // Format HH:mm
    controller.text = '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';

    // Mise à jour du ViewModel
    onTimeChanged(picked);
  }
}
