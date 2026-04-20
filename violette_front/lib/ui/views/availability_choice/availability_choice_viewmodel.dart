import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:violette_front/app/app.router.dart';

import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/availability_repository.dart';
import '../../../app/app.locator.dart';

// TODO: Refactoriser la classe quand des tests unitaires seront en place
// certaine variable pourrait être supprimmé comme _lastTappedDay ou selectDay
class AvailabilityChoiceViewModel extends BaseViewModel {
  // Attributs du widget DayCell a rajouter ici?

  final _navigationService = locator<NavigationService>();
  final ShowDateRepository _showDateRepository = locator<ShowDateRepository>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final FirebaseAuthenticationService _authenticationService =
      locator<FirebaseAuthenticationService>();
  final AvailabilityRepository _availabilityRepository =
      locator<AvailabilityRepository>();

  final CalendarFormat calendarFormat = CalendarFormat.month;
  // Le mois/la page actuellement affichée dans le calendrier
  DateTime focusedDay = DateTime.now();

  // Le jour surligné (sélection visuelle)
  DateTime? selectedDay;

  // La ShowDate du jour sélectionné (pour afficher le détail en bas)
  ShowDate? showDatePicked;

  // Sert à détecter un 2e tap sur le même jour
  DateTime? _lastTappedDay;

  List<ShowDate> showDates = [];
  final Map<String, AvailabilityStatus> _myAvailabilityByShowDateId = {};

  Future<void> loadShowDates() async {
    // runBusyFuture sert à faire un setBusy true + await + setBusy false.
    showDates = await runBusyFuture(_showDateRepository.getAllShowDates());
    await _loadMyAvailabilities();
    rebuildUi();
  }

  Future<void> _loadMyAvailabilities() async {
    _myAvailabilityByShowDateId.clear();

    final currentUser = _authenticationService.currentUser;
    if (currentUser == null) return;

    for (final showDate in showDates) {
      final showDateId = showDate.id;
      if (showDateId.isEmpty) continue;

      try {
        final availabilities =
            await _availabilityRepository.getAvailabilitiesForDate(showDateId);
        for (final availability in availabilities) {
          if (availability.artistId == currentUser.uid) {
            _myAvailabilityByShowDateId[showDateId] = availability.status;
            break;
          }
        }
      } catch (_) {
        // Toléré en phase de migration : on garde l'affichage "pending".
      }
    }
  }

  // Appelé quand l'utilisateur tape un jour.
  // - tappedDay : le jour tapé (événement)
  // - newFocusedDay : la page/mois à afficher
  Future<void> onDaySelected(DateTime tappedDay, DateTime newFocusedDay) async {
    // Remplacer par
    // void onShowDateTapped(ShowDate tappedShowDate) -> nouveau nom
    focusedDay = newFocusedDay;

    final picked = _findShowDate(tappedDay);

    // Si aucune ShowDate ce jour-là : on désélectionne tout
    if (picked == null) {
      selectedDay = null;
      showDatePicked = null;
      _lastTappedDay = null;
      rebuildUi();
      return;
    }

    // 1er tap sur ce jour : on sélectionne + on affiche en bas
    if (_lastTappedDay == null || !_isSameDay(_lastTappedDay!, tappedDay)) {
      selectedDay = tappedDay; // pour entourer
      showDatePicked = picked; // pour afficher dans le widget en bas
      _lastTappedDay = tappedDay; // mémorisation pour détecter le 2e tap
      rebuildUi();
      return;
    }

    // 2e tap sur le même jour : on change le statut côté backend.
    if (_authenticationService.currentUser != null && picked.id.isNotEmpty) {
      final currentStatus =
          getStatusForDay(tappedDay) ?? AvailabilityStatus.pending;
      final nextStatus = currentStatus.next;

      try {
        await runBusyFuture(
          _availabilityRepository.upsertMyAvailability(
            showDateId: picked.id,
            status: nextStatus,
          ),
          throwException: true,
        );

        // Mise à jour locale pour refléter immédiatement la réponse utilisateur.
        _myAvailabilityByShowDateId[picked.id] = nextStatus;
      } catch (_) {
        _snackbarService.showSnackbar(
          message: "Impossible d'enregistrer la disponibilité.",
          duration: const Duration(seconds: 3),
        );
      }

      rebuildUi();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  //Methode proposé dans la doc table_calendar appelé quand on swipe vers un autre mois
  void onPageChange(DateTime newFocusedDay) {
    focusedDay = newFocusedDay;
    rebuildUi();
  }

  // Associé au selectedDayPredicate du TableCalendar pour surligner le jour selectionné
  bool isSelectedDay(DateTime day) {
    // Retourne true uniquement si 'day' est la date que l’utilisateur a sélectionnée
    return selectedDay != null && isSameDay(day, selectedDay);
  }

  Future<void> onValidatePressed() async {
    _navigationService.replaceWithHomeView();
    _snackbarService.showSnackbar(
      message: "Disponibilités enregistrées.",
      duration: const Duration(seconds: 3),
    );
  }

//****************************************************************************//
//HELPERS                                                                     //
//****************************************************************************//
  // Récupérer le statut pour un jour
  AvailabilityStatus? getStatusForDay(DateTime day) {
    final showDate = _findShowDate(day);
    if (showDate == null) {
      return null;
    }
    final showDateId = showDate.id;
    if (_authenticationService.currentUser == null || showDateId.isEmpty) {
      return AvailabilityStatus.pending;
    }

    return _myAvailabilityByShowDateId[showDateId] ?? AvailabilityStatus.pending;
  }

  // Récupérer la ShowDate pour un jour
  //TODO Attention a adapter quand il y aura plusieurs dates pour un même jour
  ShowDate? _findShowDate(DateTime day) {
    for (ShowDate showDate in showDates) {
      if (isSameDay(showDate.date, day)) {
        return showDate;
      }
    }
    return null;
  }
}
