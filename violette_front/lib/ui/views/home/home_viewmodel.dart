import 'dart:async';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:violette_front/app/app.bottomsheets.dart';
import 'package:violette_front/app/app.dialogs.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
import 'package:violette_front/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../models/violette_user.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/enums/role.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/user_repository.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _userRepository = locator<UserRepository>();
  final _navigationService = locator<NavigationService>();
  final _bookingRepository = locator<BookingRepository>();
  final _showDateRepository = locator<ShowDateRepository>();
  final _snackbarService = locator<SnackbarService>();

  VioletteUser? currentUser;
  List<ArtistBooking> pendingRequests = [];
  Map<String, ShowDate> requestsShowDates = {};
  StreamSubscription<List<ArtistBooking>>? _pendingRequestsSub;

  void logOut() {
    _authenticationService.logout();
  }

  void navigateToAvailabilityChoiceView() {
    _navigationService.navigateToAvailabilityChoiceView();
  }

  void navigateToManagerPlanningView() {
    _navigationService.navigateToManagerPlanningView();
  }

  void navigateToShowDateFormView() {
    _navigationService.navigateToCreateShowDateView();
  }

  Future<void> loadUser() async {
    setBusy(true);

    final firebaseUser = _authenticationService.currentUser;
    if (firebaseUser == null) {
      setBusy(false);

      _navigationService.replaceWithLoginView();
      return;
    }

    final uid = firebaseUser.uid;
    currentUser = await _userRepository.getUser(uid);

    // Si l'utilisateur courant est un artiste, on écoute ses demandes de confirmation en attente.
// Objectif : afficher sur la home une liste "Demandes en attente" avec Accept / Refuse.
    if (currentUser != null && currentUser!.roles.contains(Role.artist)) {
      _listenToPendingRequests(uid);
    }

    setBusy(false);
    rebuildUi();
  }

  /// Subscription utilisée pour écouter les demandes en attente.
  /// À déclarer en attribut dans la classe : StreamSubscription<List<ArtistBooking>>? _pendingRequestsSub;
  void _listenToPendingRequests(String artistId) {
    // IMPORTANT : stocker la subscription pour pouvoir l'annuler dans dispose()
    _pendingRequestsSub?.cancel();
    _pendingRequestsSub = _bookingRepository
        .watchPendingRequestsForArtist(artistId)
        .listen((bookings) async {
      pendingRequests = bookings;

      // Pré-charge les ShowDates liés aux demandes afin d'afficher les détails (titre, date, cachet, etc.)
      await _loadShowDatesForRequests();

      rebuildUi();
    });
  }

  /// Charge les ShowDates manquants associés aux bookings en attente.
  ///
  /// Note : pour un MVP, on récupère chaque ShowDate via getShowDateStream(...).first
  /// afin d'obtenir une lecture "one-shot" sans avoir à implémenter tout de suite un getById.
  /// On stocke le résultat dans un cache (requestsShowDates) pour éviter les rechargements.
  Future<void> _loadShowDatesForRequests() async {
    for (final booking in pendingRequests) {
      final dateId = booking.dateId;

      // On ignore les bookings incomplets
      if (dateId == null) continue;

      // Si la date est déjà en cache, pas besoin de la recharger
      if (requestsShowDates.containsKey(dateId)) continue;

      try {
        // Récupération "one-shot" de la date via le stream
        final showDate = await _showDateRepository.watchShowDate(dateId).first;
        requestsShowDates[dateId] = showDate;
      } catch (_) {
        // Cas possible : la date a été supprimée ou inaccessible (droits / réseau)
        // On n'affiche simplement pas les détails de cette date.
      }
    }

    // Nettoyage optionnel : enlever du cache les dates qui ne sont plus référencées
    // (utile si la liste pendingRequests change souvent).
    final validIds =
        pendingRequests.map((b) => b.dateId).whereType<String>().toSet();

    requestsShowDates.removeWhere((key, _) => !validIds.contains(key));
  }

  /// Répond à une demande de confirmation (acceptation ou refus).
  ///
  /// - accept == true  => pendingConfirmation -> confirmed
  /// - accept == false => pendingConfirmation -> refused (et libère une place côté gérant)
  Future<void> respondToRequest(ArtistBooking booking, bool accept) async {
    final dateId = booking.dateId;
    if (dateId == null) return;

    // Optimistically disable interaction or show simple loading if needed,
    // but for "window closing" effect, we will just proceed.

    try {
      await _bookingRepository.respondToRequest(
          dateId, booking.artistId, accept);

      // Feedback
      _snackbarService.showSnackbar(
        message: accept
            ? "C'est noté ! Présence confirmée."
            : "C'est noté ! Date refusée.",
        duration: const Duration(seconds: 2),
      );

      // Optimistic Update: Remove from list immediately
      pendingRequests.removeWhere(
          (b) => b.artistId == booking.artistId && b.dateId == dateId);
      rebuildUi();
    } catch (e) {
      _dialogService.showDialog(
        title: 'Erreur',
        description: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _pendingRequestsSub?.cancel();
    super.dispose();
  }

  ////////// CI DESSOUS FONCTIONS CREE PAR STACKED //////////

  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Violllleeeeeettttttteeee',
      description:
          'Salut ${currentUser!.firstName} tu es notre ${currentUser!.roles[0]} préféré!',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }
}
