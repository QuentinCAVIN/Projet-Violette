import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/services/show_date_service.dart';
class ManagerPlanningViewModel extends BaseViewModel {
  final _showDateService = locator<ShowDateService>();
  final _navigationService = locator<NavigationService>();
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  ShowDate? showDatePicked;
  List<ShowDate> showDates = [];
  Future<void> loadShowDates() async {
    setBusy(true);
    showDates = await _showDateService.getAllShowDates();
    setBusy(false);
  }
  void onDaySelected(DateTime tappedDay, DateTime newFocusedDay) {
    focusedDay = newFocusedDay;

    final picked = _findShowDate(tappedDay);
    if (picked == null) {
      selectedDay = null;
      showDatePicked = null;
    } else {
      selectedDay = tappedDay;
      showDatePicked = picked;
    }
    rebuildUi();
  }
  void onPageChange(DateTime newFocusedDay) {
    focusedDay = newFocusedDay;
    rebuildUi();
  }
  bool isSelectedDay(DateTime day) {
    return selectedDay != null &&
        day.year == selectedDay!.year &&
        day.month == selectedDay!.month &&
        day.day == selectedDay!.day;
  }
  // Helper
  ShowDate? _findShowDate(DateTime day) {
    for (ShowDate showDate in showDates) {
      if (showDate.date.year == day.year &&
          showDate.date.month == day.month &&
          showDate.date.day == day.day) {
        return showDate;
      }
    }
    return null;
  }
  // Helper pour retourner la couleur directement (utilisé par le calendrier)
  Color? getColorForDay(DateTime day) {
    return _findShowDate(day)?.status.color;
  }
}
