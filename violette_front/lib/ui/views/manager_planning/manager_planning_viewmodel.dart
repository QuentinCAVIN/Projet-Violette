import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/violette_user.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/user_repository.dart';

class ManagerPlanningViewModel extends BaseViewModel {
  final _showDateRepository = locator<ShowDateRepository>();
  final _userRepository = locator<UserRepository>();

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  ShowDate? showDatePicked;
  List<ShowDate> showDates = [];
  List<VioletteUser> artists = [];
  String? expandedShowDateId;

  Future<void> loadShowDates() async {
    await runBusyFuture(
      () async {
        //TODO: Ok pour le MVP mais à optimiser plus tard avec un stream
        showDates = await _showDateRepository.getAllShowDates();
      }(),
    );
    rebuildUi();
  }

  final _navigationService = locator<NavigationService>();

  void navigateToDetail(ShowDate showDate) {
    _navigationService.navigateTo(
      Routes.managerDateDetailView,
      arguments: ManagerDateDetailViewArguments(showDate: showDate),
    );
  }

  Future<void> onDaySelected(DateTime tappedDay, DateTime newFocusedDay) async {
    focusedDay = newFocusedDay;
    expandedShowDateId = null;

    final picked = _findShowDate(tappedDay);
    if (picked == null) {
      selectedDay = null;
      showDatePicked = null;
    } else {
      selectedDay = tappedDay;
      showDatePicked = picked;
      await _loadArtistsForDate(picked);
    }
    rebuildUi();
  }

  Future<void> _loadArtistsForDate(ShowDate date) async {
    await runBusyFuture(
      () async {
        artists.clear();

        final artistIds = date.artistsAvailability.entries
            .where((entry) => entry.value != AvailabilityStatus.pending)
            .map((entry) => entry.key)
            .toList();

        for (final uid in artistIds) {
          final user = await _userRepository.getUser(uid);
          if (user != null) {
            artists.add(user);
          }
        }
      }(),
    );
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

  bool isExpanded(ShowDate date) {
    if (date.uid == null) return false;
    return expandedShowDateId == date.uid;
  }

  void toggleExpanded(ShowDate date) {
    final id = date.uid;
    if (id == null) return;

    if (expandedShowDateId == id) {
      expandedShowDateId = null;
    } else {
      expandedShowDateId = id;
    }

    rebuildUi();
  }
}
