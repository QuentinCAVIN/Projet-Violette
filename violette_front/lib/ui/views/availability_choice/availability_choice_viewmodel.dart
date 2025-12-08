import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityChoiceViewModel extends BaseViewModel {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

////////Test du calendrier avec liste en mémoire
  final List<DateTime> testDates = [];

  AvailabilityChoiceViewModel() {
    testDates.addAll([
      DateTime(2025, 12, 10),
      DateTime(2025, 12, 12),
      DateTime(2025, 12, 15),
      DateTime(2025, 12, 18),
      DateTime(2025, 12, 21),
    ]);
  }
///////

  void onDaySelected(newSelectedDay, newFocusedDay) {
    selectedDay = newSelectedDay;
    focusedDay = newFocusedDay;

    // Logique pour mettre a jour la liste test en mémoire
    final index = testDates.indexWhere((date) =>
        isSameDay(date, newSelectedDay));
    if (index >= 0) {
      testDates.removeAt(index);
    } else {
      testDates.add(newSelectedDay);
    }
    rebuildUi();
  }

  void onFormatChanged(CalendarFormat format) {
    if (calendarFormat != format) {
      calendarFormat = format;
      rebuildUi();
    }
  }

  void onPageChange(DateTime focusDay) {
    focusedDay = focusedDay;
    rebuildUi();
  }


  bool isDateProposed(DateTime day) {
    return testDates.any((date) => isSameDay(date, day));
  }
}