import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/availability_status.dart';

class AvailabilityChoiceViewModel extends BaseViewModel {

  // Attributs du widget DayCell

  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

//****************************************************************************//
  // Liste des ShowDate en mémoire pour l’instant
  final List<ShowDate> showDates = [];
  AvailabilityChoiceViewModel() {
    // pour tester le calendrier
    showDates.addAll([
      ShowDate(
        uid: "1",
        date: DateTime(2025, 12, 10),
        availabilityStatus: AvailabilityStatus.available,
      ),
      ShowDate(
        uid: "2",
        date: DateTime(2025, 12, 12),
        availabilityStatus: AvailabilityStatus.conditional,
      ),
      ShowDate(
        uid: "3",
        date: DateTime(2025, 12, 15),
        availabilityStatus: AvailabilityStatus.unavailable,
      ),
      ShowDate(
        uid: "4",
        date: DateTime(2025, 12, 18),
        availabilityStatus: AvailabilityStatus.pending,
      ),
      ShowDate(
        uid: "5",
        date: DateTime(2025, 12, 21),
        availabilityStatus: AvailabilityStatus.available,
      ),
    ]);
  }
//****************************************************************************//

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
