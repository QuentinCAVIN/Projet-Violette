import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/app/app.router.dart';
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
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _userRepository = locator<UserRepository>();
  final _navigationService = locator<NavigationService>();
  final _bookingRepository = locator<BookingRepository>();
  final _showDateRepository = locator<ShowDateRepository>();
  final _snackbarService = locator<SnackbarService>();

  VioletteUser? currentUser;

  List<ArtistBooking> pendingRequests = [];
  Map<String, ShowDate> requestsShowDates = {};

  Future<void> logOut() async {
    await _authenticationService.logout();
    _navigationService.replaceWithLoginView();
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
    try {
      final firebaseUser = _authenticationService.currentUser;
      if (firebaseUser == null) {
        _navigationService.replaceWithLoginView();
        return;
      }

      final uid = firebaseUser.uid;
      try {
        currentUser = await _userRepository.getUser(uid);
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Profil utilisateur',
          description:
              'Impossible de charger le profil depuis le backend. '
              'Vérifie le démarrage Quarkus (profil firebase, FIREBASE_PROJECT_ID) '
              'et la connexion réseau (adb reverse sur téléphone USB). '
              '\n\n$e',
        );
        currentUser = null;
        return;
      }

      if (currentUser == null) {
        await _authenticationService.logout();
        _navigationService.replaceWithLoginView();
        return;
      }

      if (currentUser!.roles.contains(Role.artist)) {
        await _loadPendingRequests(uid);
      }
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  /// Charge les demandes de confirmation en attente (REST `GET .../me/pending`).
  ///
  /// Remplace l’ancien flux temps réel Firestore (`watchPendingRequestsForArtist`).
  Future<void> _loadPendingRequests(String artistId) async {
    try {
      pendingRequests =
          await _bookingRepository.getPendingRequestsForArtist(artistId);
      await _loadShowDatesForRequests();
    } catch (_) {
      pendingRequests = [];
      _snackbarService.showSnackbar(
        message: 'Impossible de charger les demandes en attente.',
        duration: const Duration(seconds: 3),
      );
    }
    rebuildUi();
  }

  /// Charge les ShowDates manquants associés aux demandes en attente.
  Future<void> _loadShowDatesForRequests() async {
    for (final booking in pendingRequests) {
      final dateId = booking.dateId;

      if (dateId == null || dateId.isEmpty) continue;

      if (requestsShowDates.containsKey(dateId)) continue;

      try {
        final showDate = await _showDateRepository.getShowDateById(dateId);
        if (showDate != null) {
          requestsShowDates[dateId] = showDate;
        }
      } catch (_) {}
    }

    final validIds =
        pendingRequests.map((b) => b.dateId).whereType<String>().toSet();

    requestsShowDates.removeWhere((key, _) => !validIds.contains(key));
  }

  /// Répond à une demande de confirmation (acceptation ou refus).
  ///
  /// Persistance : [BookingRepository.respondToRequest] (REST). Après succès,
  /// la liste est rechargée depuis le serveur via [_loadPendingRequests].
  Future<void> respondToRequest(ArtistBooking booking, bool accept) async {
    final dateId = booking.dateId;
    if (dateId == null) return;

    try {
      await _bookingRepository.respondToRequest(
          dateId, booking.artistId, accept);

      _snackbarService.showSnackbar(
        message: accept
            ? "C'est noté ! Présence confirmée."
            : "C'est noté ! Date refusée.",
        duration: const Duration(seconds: 2),
      );

      final uid = _authenticationService.currentUser?.uid;
      if (uid != null && currentUser?.roles.contains(Role.artist) == true) {
        await _loadPendingRequests(uid);
      } else {
        pendingRequests.removeWhere(
            (b) => b.artistId == booking.artistId && b.dateId == dateId);
        rebuildUi();
      }
    } catch (e) {
      _dialogService.showDialog(
        title: 'Erreur',
        description: e.toString(),
      );
    }
  }

}
