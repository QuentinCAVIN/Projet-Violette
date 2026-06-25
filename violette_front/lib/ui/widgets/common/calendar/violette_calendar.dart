import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_day_cell.dart';

class VioletteCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final bool Function(DateTime) selectedDayPredicate;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  /// Fonction pour déterminer la couleur d'un jour (ex: statut)
  /// Si null est retourné, le jour s'affiche normalement.
  final Color? Function(DateTime)? dayColorBuilder;

  /// Libellé verbalisé du statut du jour (ex: disponibilité) pour l'accessibilité.
  final String? Function(DateTime)? dayStatusLabelBuilder;

  const VioletteCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    this.calendarFormat = CalendarFormat.month,
    required this.selectedDayPredicate,
    required this.onDaySelected,
    required this.onPageChanged,
    this.dayColorBuilder,
    this.dayStatusLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      selectedDayPredicate: selectedDayPredicate,
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarStyle: const CalendarStyle(
        isTodayHighlighted:
            false, // On gère nous même le highlight via le builders
      ),
      calendarBuilders: CalendarBuilders(
        // Builder par défaut
        defaultBuilder: (context, day, focusedDay) {
          return CalendarDayCell(
            day: day,
            color: dayColorBuilder?.call(day),
            statusLabel: dayStatusLabelBuilder?.call(day),
          );
        },
        // Builder jour sélectionné
        selectedBuilder: (context, day, focusedDay) {
          return CalendarDayCell(
            day: day,
            color: dayColorBuilder?.call(day),
            statusLabel: dayStatusLabelBuilder?.call(day),
            isSelected: true,
          );
        },
        // Builder jour d'aujourd'hui
        todayBuilder: (context, day, focusedDay) {
          return CalendarDayCell(
            day: day,
            color: dayColorBuilder?.call(day),
            statusLabel: dayStatusLabelBuilder?.call(day),
            isToday: true,
          );
        },
        // Jours hors mois
        outsideBuilder: (context, day, focusedDay) {
          return Opacity(
            opacity: 0.4,
            child: CalendarDayCell(
              day: day,
              color: dayColorBuilder?.call(day),
              statusLabel: dayStatusLabelBuilder?.call(day),
            ),
          );
        },
      ),
    );
  }
}
