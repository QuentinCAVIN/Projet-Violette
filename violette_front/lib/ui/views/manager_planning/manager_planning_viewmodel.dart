import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/violette_user.dart';
import 'package:violette_front/repositories/availability_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/user_repository.dart';

class ManagerPlanningViewModel extends BaseViewModel {
  final _showDateRepository = locator<ShowDateRepository>();
  final _userRepository = locator<UserRepository>();
  final _availabilityRepository = locator<AvailabilityRepository>();

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  ShowDate? showDatePicked;
  List<ShowDate> selectedShowDates = [];
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

  Future<void> refreshShowDateAfterStatusChange(ShowDate updatedShowDate) async {
    if (updatedShowDate.id.isEmpty) {
      await loadShowDates();
      return;
    }

    final index = showDates.indexWhere((date) => date.id == updatedShowDate.id);
    if (index >= 0) {
      showDates[index] = updatedShowDate;
    } else {
      await loadShowDates();
      return;
    }

    if (showDatePicked?.id == updatedShowDate.id) {
      showDatePicked = updatedShowDate;
    }
    final selectedIndex =
        selectedShowDates.indexWhere((date) => date.id == updatedShowDate.id);
    if (selectedIndex >= 0) {
      selectedShowDates[selectedIndex] = updatedShowDate;
    }

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
    selectedDay = tappedDay;

    final pickedDates = _findShowDatesForDay(tappedDay);
    selectedShowDates = pickedDates;
    if (pickedDates.isEmpty) {
      showDatePicked = null;
      artists = [];
    } else {
      showDatePicked = pickedDates.first;
      await _loadArtistsForDate(pickedDates.first);
    }
    rebuildUi();
  }

  Future<void> _loadArtistsForDate(ShowDate date) async {
    await runBusyFuture(
      () async {
        artists.clear();

        final dateId = date.id;
        if (dateId.isEmpty) return;

        final availabilities =
            await _availabilityRepository.getAvailabilitiesForDate(dateId);

        final artistIds = availabilities
            .where((availability) => availability.status != AvailabilityStatus.pending)
            .map((availability) => availability.artistId)
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
  List<ShowDate> _findShowDatesForDay(DateTime day) {
    return showDates
        .where((showDate) =>
            showDate.date.year == day.year &&
            showDate.date.month == day.month &&
            showDate.date.day == day.day)
        .toList();
  }

  // Helper pour retourner la couleur directement (utilisé par le calendrier)
  Color? getColorForDay(DateTime day) {
    final datesForDay = _findShowDatesForDay(day);
    if (datesForDay.isEmpty) return null;
    return _pickCalendarStatus(datesForDay).color;
  }

  ShowDateStatus _pickCalendarStatus(List<ShowDate> datesForDay) {
    // Règle simple v0.4.0 en cas de statuts mixtes sur un même jour :
    // on affiche la couleur du statut le plus "prioritaire" opérationnel.
    // Priorité décroissante : CONFIRMED > OPTION > INQUIRY > STAFFED > CANCELLED > ARCHIVED
    const priorities = {
      ShowDateStatus.confirmed: 6,
      ShowDateStatus.option: 5,
      ShowDateStatus.inquiry: 4,
      ShowDateStatus.staffed: 3,
      ShowDateStatus.cancelled: 2,
      ShowDateStatus.archived: 1,
    };

    ShowDateStatus selectedStatus = datesForDay.first.status;
    int selectedPriority = priorities[selectedStatus] ?? 0;

    for (final showDate in datesForDay.skip(1)) {
      final priority = priorities[showDate.status] ?? 0;
      if (priority > selectedPriority) {
        selectedStatus = showDate.status;
        selectedPriority = priority;
      }
    }

    return selectedStatus;
  }

  bool isExpanded(ShowDate date) {
    if (date.id.isEmpty) return false;
    return expandedShowDateId == date.id;
  }

  void toggleExpanded(ShowDate date) {
    final id = date.id;
    if (id.isEmpty) return;

    if (expandedShowDateId == id) {
      expandedShowDateId = null;
    } else {
      expandedShowDateId = id;
    }

    rebuildUi();
  }
}
