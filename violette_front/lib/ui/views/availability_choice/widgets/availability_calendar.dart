import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import '../availability_choice_viewmodel.dart';
import 'day_cell.dart';

class AvailabilityCalendar
    extends ViewModelWidget<AvailabilityChoiceViewModel> {
  const AvailabilityCalendar({super.key});

  @override
  Widget build(
    BuildContext context,
    AvailabilityChoiceViewModel viewModel,
  ) {
    // DETTE-10 : retirer ou activer le bouton « 2 weeks » du calendrier TableCalendar
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: viewModel.focusedDay,
      calendarFormat: viewModel.calendarFormat,
      selectedDayPredicate: viewModel.isSelectedDay,
      onDaySelected: viewModel.onDaySelected,
      onPageChanged: viewModel.onPageChange,
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
      ),

      //Voir doc de TableCalendar sur les builders
      calendarBuilders: CalendarBuilders(
        //Builder pour les jours par defaut (sans date proposé)
        defaultBuilder: (context, day, focusedDay) {
          return DayCell(
            day: day,
            status: viewModel.getStatusForDay(day),
          );
        },
        // Builder pour construire uniquement les jours selectionnées par le selectedDayPredicate
        selectedBuilder: (context, day, focusedDay) {
          return DayCell(
            day: day,
            status: viewModel.getStatusForDay(day),
            isSelected: true,
          );
        },
        // Builder pour le jour présent
        todayBuilder: (context, day, focusedDay) {
          return DayCell(
            day: day,
            status: viewModel.getStatusForDay(day),
          );
        },
        // Jours du mois précédent/suivant affichés
        outsideBuilder: (context, day, focusedDay) {
          return Opacity(
            opacity: 0.4,
            child: DayCell(
              day: day,
              status: viewModel.getStatusForDay(day),
            ),
          );
        },
      ),
    );
  }
}
