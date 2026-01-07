import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:violette_front/app/app.router.dart';

import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/services/show_date_service.dart';

import '../../../app/app.locator.dart';

// TODO: Refactoriser la classe quand des tests unitaires seront en place
// certaine variable pourrait être supprimmé comme _lastTappedDay ou selectDay
class AvailabilityChoiceViewModel extends BaseViewModel {
  // Attributs du widget DayCell a rajouter ici?

  final _navigationService = locator<NavigationService>();
  final ShowDateService _showDateService = locator<ShowDateService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final FirebaseAuthenticationService _authenticationService =
      locator<FirebaseAuthenticationService>();

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

  Future<void> loadShowDates() async {
    //runBusyFuture sert a fair un setBusy true + await + setBusyFalse
    showDates = await runBusyFuture(_showDateService.getAllShowDates());
  }

  // Appelé quand l'utilisateur tape un jour.
  // - tappedDay : le jour tapé (événement)
  // - newFocusedDay : la page/mois à afficher
  void onDaySelected(DateTime tappedDay, DateTime newFocusedDay) {
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

    // 2e tap sur le même jour : on change le statut
    if (_authenticationService.currentUser != null) {
      picked.nextStatus(_authenticationService.currentUser!.uid);
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
    await runBusyFuture(_showDateService.updateAllShowDates(showDates));
    _navigationService.replaceWithHomeView();
    // Affiche le message une fois sur HomeView
    _snackbarService.showSnackbar(
      message: "Disponibilités enregistrées !",
      duration: const Duration(seconds: 3),
    );
  }

//****************************************************************************//
//HELPERS                                                                     //
//****************************************************************************//
  // Récupérer le statut pour un jour
  AvailabilityStatus getStatusForDay(DateTime day) {
    final showDate = _findShowDate(day);
    if (showDate == null || _authenticationService.currentUser == null) {
      return AvailabilityStatus.pending;
    }
    return showDate.getAvailabilityFor(_authenticationService.currentUser!.uid);
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
