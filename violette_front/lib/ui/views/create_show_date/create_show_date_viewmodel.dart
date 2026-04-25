import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';

import '../../../models/show_date.dart';
import '../../../repositories/show_date_repository.dart';
import 'create_show_date_view.form.dart';

class CreateShowDateViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _showDateRepository = locator<ShowDateRepository>();

  bool formAlreadyValidatedOnce = false;

  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;

  /// Champs requis par le backend REST mais hors `@FormView` — ils restent
  /// gérés ici ; le reste du formulaire vient de `create_show_date_view.form.dart`
  /// (généré par `dart run build_runner build`).
  final TextEditingController clientContactNameController =
      TextEditingController();
  final TextEditingController clientContactPhoneController =
      TextEditingController();

  String? clientContactNameError;
  String? clientContactPhoneError;

  @override
  void dispose() {
    clientContactNameController.dispose();
    clientContactPhoneController.dispose();
    super.dispose();
  }

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  @override
  void setFormStatus() {
    setTitleValidationMessage(null);
    setDateValidationMessage(null);
    setStartTimeValidationMessage(null);
    setAddressValidationMessage(null);
    setArtistsCountValidationMessage(null);
    setDescriptionValidationMessage(null);
    clientContactNameError = null;
    clientContactPhoneError = null;

    if (!formAlreadyValidatedOnce) {
      return;
    }

    if (titleValue == null || titleValue!.trim().isEmpty) {
      setTitleValidationMessage('Le nom du spectacle est obligatoire');
    }

    if (dateValue == null || dateValue!.trim().isEmpty) {
      setDateValidationMessage('La date est obligatoire');
    }

    if (startTimeValue == null || startTimeValue!.trim().isEmpty) {
      setStartTimeValidationMessage('Heure de convocation obligatoire');
    }

    if (addressValue == null || addressValue!.trim().isEmpty) {
      setAddressValidationMessage('Adresse obligatoire');
    }

    if (artistsCountValue != null && artistsCountValue!.isNotEmpty) {
      final parsed = int.tryParse(artistsCountValue!);
      if (parsed == null || parsed <= 0) {
        setArtistsCountValidationMessage('Nombre d’artistes invalide');
      }
    }

    if (artistsCountValue == null || artistsCountValue!.trim().isEmpty) {
      setArtistsCountValidationMessage('Nombre d’artistes obligatoire');
    }

    if (clientContactNameController.text.trim().isEmpty) {
      clientContactNameError = 'Nom du contact client obligatoire';
    }
    if (clientContactPhoneController.text.trim().isEmpty) {
      clientContactPhoneError = 'Téléphone du contact client obligatoire';
    }
  }

  void onDateChanged(DateTime date) {
    selectedDate = date;
    setFormStatus();
    rebuildUi();
  }

  void onStartTimeChanged(TimeOfDay time) {
    selectedStartTime = time;
    setFormStatus();
    rebuildUi();
  }

  Future<void> submitShowDateForm() async {
    formAlreadyValidatedOnce = true;

    setFormStatus();
    rebuildUi();

    if (!isFormValid) {
      return;
    }

    if (clientContactNameError != null || clientContactPhoneError != null) {
      return;
    }

    final showDate = ShowDate(
      title: titleValue!,
      date: DateTime.utc(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        12,
      ),
      meetingTimeMinutes: _timeOfDayToMinutes(selectedStartTime!),
      address: addressValue!,
      totalRequiredArtists: int.parse(artistsCountValue!),
      description: descriptionValue,
      clientContactName: clientContactNameController.text.trim(),
      clientContactPhone: clientContactPhoneController.text.trim(),
    );

    try {
      await runBusyFuture(_showDateRepository.addShowDate(showDate));
      _navigationService.replaceWithHomeView();
    } catch (e) {
      final message = e.toString();
      final isNoCompanyError = message.contains('aucune compagnie associée');

      await _dialogService.showDialog(
        title: 'Création de date impossible',
        description: isNoCompanyError
            ? 'Impossible de créer la date. Votre compte manager n’est associé à aucune compagnie.'
            : 'Impossible de créer la date pour le moment. Merci de réessayer.',
      );
    }
  }

  void navigateBack() {
    _navigationService.back();
  }
}
