import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import '../../../models/enums/availability_status.dart';
import '../../../models/show_date.dart';
import '../../../services/show_date_service.dart';
import 'create_show_date_view.form.dart';


class CreateShowDateViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  final _showDateService = locator<ShowDateService>();

  String? globalErrorMessage;
  bool formAlreadyValidatedOnce = false;

  // Appelé à chaque changement de champs par Stacked
  @override
  void setFormStatus() {
    // Réinitialisation des messages d'erreur
    setTitleValidationMessage(null);
    setDateValidationMessage(null);
    setStartTimeValidationMessage(null);
    setEndTimeValidationMessage(null);
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
  void onDateChanged() {
    setFormStatus();
    rebuildUi();
  }

  void onTimeChanged() {
    setFormStatus();
    rebuildUi();
  }

  Future<void> submitShowDateForm() async {
    formAlreadyValidatedOnce = true;
    globalErrorMessage = null;

    setFormStatus();
    rebuildUi();

    if (!isFormValid) {
      return;
    }

    // TODO: construire un objet ShowDate avec toute les valeurs plus tard
    // Pour l'instant on utilise que la date et on fixe le statut à en attente
     final showDate = ShowDate(
      date: _dateStringToDateTime(dateValue!),
      availabilityStatus: AvailabilityStatus.pending,
    );
     await runBusyFuture(_showDateService.addShowDate(showDate));
    _navigationService.replaceWithHomeView();
  }

  void navigateBack() {
    _navigationService.back();
  }
}


//TOdo A mettre dans une classe DateHelper

DateTime _dateStringToDateTime(String value) {

    final parts = value.split('/'); // "12/02/2026" -> ["12","02","2026"]

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    return DateTime(year, month, day);
}