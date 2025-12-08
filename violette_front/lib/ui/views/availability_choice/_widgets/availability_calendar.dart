import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import '../availability_choice_viewmodel.dart';

class AvailabilityCalendar extends ViewModelWidget <AvailabilityChoiceViewModel> {
  const AvailabilityCalendar({super.key});

  @override
  Widget build(
    BuildContext context,
      AvailabilityChoiceViewModel viewModel,
  ) {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: viewModel.focusedDay,
      calendarFormat: viewModel.calendarFormat,
      selectedDayPredicate: viewModel.isDateProposed,
      onDaySelected: viewModel.onDaySelected,
      onFormatChanged: viewModel.onFormatChanged,
      onPageChanged: viewModel.onPageChange,
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
      ),
    );
  }
}

// Composant table_calendar adapté en stack view https://pub.dev/packages/table_calendar