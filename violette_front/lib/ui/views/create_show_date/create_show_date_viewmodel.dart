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
  final _showDateRepository = locator<ShowDateRepository>();

  String? globalErrorMessage;
  bool formAlreadyValidatedOnce = false;

  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  // Appelé à chaque changement de champs par Stacked
  @override
  void setFormStatus() {
    // Réinitialisation des messages d'erreur
    setTitleValidationMessage(null);
    setDateValidationMessage(null);
    setStartTimeValidationMessage(null);
    setEndTimeValidationMessage(null);
    setAddressValidationMessage(null);
    setArtistsCountValidationMessage(null);
    setFeeValidationMessage(null);
    setDescriptionValidationMessage(null);

    if (!formAlreadyValidatedOnce) {
      return;
    }

    // Nom du spectacle
    if (titleValue == null || titleValue!.trim().isEmpty) {
      setTitleValidationMessage('Le nom du spectacle est obligatoire');
    }

    // Date
    if (dateValue == null || dateValue!.trim().isEmpty) {
      setDateValidationMessage('La date est obligatoire');
    }

    // Heures
    if (startTimeValue == null || startTimeValue!.trim().isEmpty) {
      setStartTimeValidationMessage('Heure de début obligatoire');
    }
    if (endTimeValue == null || endTimeValue!.trim().isEmpty) {
      setEndTimeValidationMessage('Heure de fin obligatoire');
    }
    if (selectedStartTime != null && selectedEndTime != null) {
      final start = _timeOfDayToMinutes(selectedStartTime!);
      final end = _timeOfDayToMinutes(selectedEndTime!);

      //Todo: Temporaire: Fixe la date au lendemain quand on fait le tour du cadran (en int minutes)
      final endAdjusted =
          (end <= start) ? end + 24 * 60 : end; // cas date de 23h à 1h00
      final duration = endAdjusted - start;
      //TODO Voir avec Agathe si on bloque une date supérieur à 12h (auto-entrepreneur)
      if (duration.abs() > 12 * 60) {
        globalErrorMessage =
            "Un cachet d'intermittent ne peut pas dépasser 12h";
      }
    }

    // Adresse
    if (addressValue == null || addressValue!.trim().isEmpty) {
      setEndTimeValidationMessage('Adresse obligatoire');
    }

    if (artistsCountValue != null && artistsCountValue!.isNotEmpty) {
      final parsed = int.tryParse(artistsCountValue!);
      if (parsed == null || parsed <= 0) {
        setArtistsCountValidationMessage('Nombre d’artistes invalide');
      }
    }

    // Artistes nécessaires
    if (artistsCountValue != null && artistsCountValue!.isNotEmpty) {
      final parsed = int.tryParse(artistsCountValue!);
      if (parsed == null || parsed <= 0) {
        setArtistsCountValidationMessage('Nombre d’artistes invalide');
      }
    }

    // Montant du cachet
    if (feeValue != null && feeValue!.isNotEmpty) {
      final parsed = double.tryParse(feeValue!.replaceAll(',', '.'));
      if (parsed == null || parsed < 0) {
        setFeeValidationMessage('Montant invalide');
      }
    }
  }

  // methodes appelés depuis le widget pour relancer la validation après un pick
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

  void onEndTimeChanged(TimeOfDay time) {
    selectedEndTime = time;
    setFormStatus();
    rebuildUi();
  }

  Future<void> submitShowDateForm() async {
    formAlreadyValidatedOnce = true;
    globalErrorMessage = null;

    setFormStatus();
    rebuildUi();

    if (!isFormValid || globalErrorMessage != null) {
      return;
    }

    final showDate = ShowDate(
      title: titleValue!,
      date: DateTime.utc(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        12, // Force à midi UTC pour éviter les décalages de fuseaux horaires
      ),
      startMinutes: _timeOfDayToMinutes(selectedStartTime!),
      endMinutes: _timeOfDayToMinutes(selectedEndTime!),
      address: addressValue!,
      artistsCount: int.parse(artistsCountValue!),
      fee: double.parse(feeValue!.replaceAll(',', '.')),
      description: descriptionValue,
    );

    await runBusyFuture(_showDateRepository.addShowDate(showDate));
    _navigationService.replaceWithHomeView();
  }

  void navigateBack() {
    _navigationService.back();
  }
}
