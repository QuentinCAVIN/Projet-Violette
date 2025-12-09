import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/availability_status.dart';
import 'package:violette_front/services/show_date_service.dart';

import '../../../app/app.locator.dart';

class AvailabilityChoiceViewModel extends BaseViewModel {
  // Attributs du widget DayCell a rajouter ici?


  final ShowDateService showDateService = locator<ShowDateService>();


  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  List<ShowDate> showDates = [];

  Future<void> loadShowDates() async {
    showDates = await runBusyFuture(showDateService.getAllShowDates());
  }

  void onDaySelected(DateTime tappedDay, DateTime newFocusedDay) {
    focusedDay = newFocusedDay;

    final existing = _findShowDate(tappedDay);

    if (existing != null) {
      // On applique le status uniquement pour les dates avec une ShowDate
      existing.availabilityStatus = _nextStatus(existing.availabilityStatus);
      selectedDay = tappedDay; // Pour entourer le jour séléctionné
    } else {
      selectedDay = null; // Pour retirer le jour sélectionné
    }
    rebuildUi();
  }

  // Methode proposé en exemple dans la doc table_calendar pour changer le format du Calendar
  void onFormatChanged(CalendarFormat format) {
    if (calendarFormat != format) {
      calendarFormat = format;
      rebuildUi();
    }
  }

  //Methode proposé dans la doc table_calendar pour changer de mois
  void onPageChange(DateTime newFocusedDay) {
    focusedDay = newFocusedDay;
    rebuildUi();
  }

  // Inutilisé pour le moment, va servir dans la vue "récap"
  bool isSelectedDay(DateTime day) {
    // Retourne true uniquement si 'day' est la date que l’utilisateur a sélectionnée
    return selectedDay != null && isSameDay(day, selectedDay);
  }

//****************************************************************************//
//HELPERS                                                                     //
//****************************************************************************//
  // Récupérer le statut pour un jour
  AvailabilityStatus? getStatusForDay(DateTime day) {
    return _findShowDate(day)?.availabilityStatus;
  }

  // Pour selectedDayPredicate (condition de selection des dates surr le calendrier
  bool isDateProposed(DateTime day) {
    return _findShowDate(day) != null;
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

  static AvailabilityStatus _nextStatus(AvailabilityStatus current) {
    switch (current) {
      case AvailabilityStatus.pending:
        return AvailabilityStatus.available;
      case AvailabilityStatus.available:
        return AvailabilityStatus.conditional;
      case AvailabilityStatus.conditional:
        return AvailabilityStatus.unavailable;
      case AvailabilityStatus.unavailable:
        return AvailabilityStatus.pending;
    }
  }
}