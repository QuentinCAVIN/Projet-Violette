import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:dio/dio.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:violette_front/app/app.router.dart';

import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/availability_repository.dart';
import '../../../app/app.locator.dart';

// TODO: Refactoriser la classe quand des tests unitaires seront en place
// certaine variable pourrait être supprimmé comme _lastTappedDay ou selectDay
class AvailabilityChoiceViewModel extends BaseViewModel {
  // Attributs du widget DayCell a rajouter ici?

  final _navigationService = locator<NavigationService>();
  final ShowDateRepository _showDateRepository = locator<ShowDateRepository>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final FirebaseAuthenticationService _authenticationService =
      locator<FirebaseAuthenticationService>();
  final AvailabilityRepository _availabilityRepository =
      locator<AvailabilityRepository>();
  final BookingRepository _bookingRepository = locator<BookingRepository>();

  final CalendarFormat calendarFormat = CalendarFormat.month;
  // Le mois/la page actuellement affichée dans le calendrier
  DateTime focusedDay = DateTime.now();

  // Le jour surligné (sélection visuelle)
  DateTime? selectedDay;

  /// Toutes les dates du jour sélectionné (même jour calendaire).
  List<ShowDate> selectedShowDates = [];

  /// Première date du jour — conservé pour compatibilité avec l’ancien flux.
  ShowDate? get showDatePicked =>
      selectedShowDates.isEmpty ? null : selectedShowDates.first;

  // Sert à détecter un 2e tap sur le même jour
  DateTime? _lastTappedDay;

  List<ShowDate> showDates = [];
  final Map<String, AvailabilityStatus> _myAvailabilityByShowDateId = {};
  final Set<String> _confirmedBookingShowDateIds = {};

  Future<void> loadShowDates() async {
    // runBusyFuture sert à faire un setBusy true + await + setBusy false.
    showDates = await runBusyFuture(_showDateRepository.getMyAvailableShowDates());
    await _loadMyAvailabilities();
    await _loadMyConfirmedBookings();
    rebuildUi();
  }

  Future<void> _loadMyAvailabilities() async {
    _myAvailabilityByShowDateId.clear();

    final currentUser = _authenticationService.currentUser;
    if (currentUser == null) return;

    for (final showDate in showDates) {
      final showDateId = showDate.id;
      if (showDateId.isEmpty) continue;

      try {
        final availability =
            await _availabilityRepository.getMyAvailabilityForDate(showDateId);
        _myAvailabilityByShowDateId[showDateId] = availability.status;
      } on DioException catch (e) {
        if (e.response?.statusCode == 403) {
          _snackbarService.showSnackbar(
            message: 'Accès refusé pour charger votre disponibilité.',
            duration: const Duration(seconds: 3),
          );
        }
      } catch (_) {
        // On conserve le statut PENDING en cas d'erreur réseau ponctuelle.
      }
    }
  }

  Future<void> _loadMyConfirmedBookings() async {
    _confirmedBookingShowDateIds.clear();

    if (_authenticationService.currentUser == null) return;

    try {
      final bookings = await _bookingRepository.getMyBookings();
      _confirmedBookingShowDateIds.addAll(
        bookings
            .where((booking) => booking.status == BookingStatus.confirmed)
            .map((booking) => booking.dateId)
            .whereType<String>()
            .where((dateId) => dateId.isNotEmpty),
      );
    } catch (_) {
      // L'absence temporaire d'information booking ne doit pas bloquer le chargement des disponibilités.
    }
  }

  // Appelé quand l'utilisateur tape un jour.
  // - tappedDay : le jour tapé (événement)
  // - newFocusedDay : la page/mois à afficher
  Future<void> onDaySelected(DateTime tappedDay, DateTime newFocusedDay) async {
    focusedDay = newFocusedDay;

    final pickedDates = _findShowDatesForDay(tappedDay);

    // Si aucune ShowDate ce jour-là : on désélectionne tout
    if (pickedDates.isEmpty) {
      selectedDay = null;
      selectedShowDates = [];
      _lastTappedDay = null;
      rebuildUi();
      return;
    }

    selectedShowDates = pickedDates;

    // 1er tap sur ce jour : on sélectionne + on affiche en bas
    if (_lastTappedDay == null || !_isSameDay(_lastTappedDay!, tappedDay)) {
      selectedDay = tappedDay; // pour entourer
      _lastTappedDay = tappedDay; // mémorisation pour détecter le 2e tap
      rebuildUi();
      return;
    }

    // 2e tap sur le même jour : cycle de disponibilité (une seule date ce jour).
    if (pickedDates.length > 1) {
      _snackbarService.showSnackbar(
        message:
            'Plusieurs spectacles ce jour : utilise le bouton sous chaque fiche.',
        duration: const Duration(seconds: 3),
      );
      rebuildUi();
      return;
    }

    final picked = pickedDates.first;
    if (_authenticationService.currentUser != null && picked.id.isNotEmpty) {
      await cycleAvailabilityForShowDate(picked);
    }
  }

  /// Passe la disponibilité de l’artiste au statut suivant pour une date donnée.
  Future<void> cycleAvailabilityForShowDate(ShowDate showDate) async {
    final id = showDate.id;
    if (id.isEmpty || _authenticationService.currentUser == null) return;

    if (isShowDateConfirmedByBooking(id)) {
      _snackbarService.showSnackbar(
        message: confirmedBookingLockMessage,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final currentStatus =
        getStatusForShowDateId(id) ?? AvailabilityStatus.pending;
    final nextStatus = currentStatus.next;

    try {
      await runBusyFuture(
        _availabilityRepository.upsertMyAvailability(
          showDateId: id,
          status: nextStatus,
        ),
        throwException: true,
      );

      _myAvailabilityByShowDateId[id] = nextStatus;
    } catch (_) {
      _snackbarService.showSnackbar(
        message: "Impossible d'enregistrer la disponibilité.",
        duration: const Duration(seconds: 3),
      );
    }

    rebuildUi();
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
    _navigationService.replaceWithHomeView();
    _snackbarService.showSnackbar(
      message: "Disponibilités enregistrées.",
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> onBackPressed() async {
    // On force un retour vers Home pour éviter de revenir sur une pile manager legacy.
    await _navigationService.clearStackAndShow(Routes.homeView);
  }

//****************************************************************************//
//HELPERS                                                                     //
//****************************************************************************//

  /// Statut de disponibilité pour une date (identifiant backend).
  AvailabilityStatus? getStatusForShowDateId(String showDateId) {
    if (showDateId.isEmpty) return null;
    if (_authenticationService.currentUser == null) {
      return AvailabilityStatus.pending;
    }

    return _myAvailabilityByShowDateId[showDateId] ??
        AvailabilityStatus.pending;
  }

  String get confirmedBookingLockMessage =>
      'Confirmé — contactez le gérant pour modifier';

  bool isShowDateConfirmedByBooking(String showDateId) =>
      _confirmedBookingShowDateIds.contains(showDateId);

  // Récupérer le statut pour un jour (calendrier : une seule couleur par jour).
  AvailabilityStatus? getStatusForDay(DateTime day) {
    final dates = _findShowDatesForDay(day);
    if (dates.isEmpty) {
      return null;
    }
    if (dates.length == 1) {
      return getStatusForShowDateId(dates.first.id);
    }
    return _pickCalendarAvailabilityStatus(dates);
  }

  /// Plusieurs ShowDate le même jour : priorité d’affichage calendrier v0.4.0
  /// (disponibilité la plus « favorable »).
  /// Ordre : available > ifNeeded > pending > unavailable
  AvailabilityStatus _pickCalendarAvailabilityStatus(List<ShowDate> datesForDay) {
    const priorities = {
      AvailabilityStatus.available: 4,
      AvailabilityStatus.ifNeeded: 3,
      AvailabilityStatus.pending: 2,
      AvailabilityStatus.unavailable: 1,
    };

    AvailabilityStatus selected = getStatusForShowDateId(datesForDay.first.id) ??
        AvailabilityStatus.pending;
    int selectedP = priorities[selected] ?? 0;

    for (final showDate in datesForDay.skip(1)) {
      final s = getStatusForShowDateId(showDate.id) ?? AvailabilityStatus.pending;
      final p = priorities[s] ?? 0;
      if (p > selectedP) {
        selected = s;
        selectedP = p;
      }
    }

    return selected;
  }

  /// Couleur du jour dans le calendrier (null = jour sans spectacle).
  Color? getColorForDay(DateTime day) => getStatusForDay(day)?.color;

  List<ShowDate> _findShowDatesForDay(DateTime day) {
    return showDates
        .where((showDate) => isSameDay(showDate.date, day))
        .toList();
  }
}
