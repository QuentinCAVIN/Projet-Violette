import 'dart:async';
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
  StreamSubscription<List<ArtistBooking>>? _pendingRequestsSub;

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
        // Erreur réseau, backend inaccessible, token invalide, etc.
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

      // getUser retourne null si le backend répond 404 (profil absent).
      // Ce cas ne devrait plus se produire grâce au routage de StartupViewModel,
      // mais peut survenir si LoginViewModel navigue ici pour un compte sans profil.
      // On déconnecte Firebase pour repartir d'un état cohérent.
      if (currentUser == null) {
        await _authenticationService.logout();
        _navigationService.replaceWithLoginView();
        return;
      }

      // Si l'utilisateur courant est un artiste, on écoute ses demandes de confirmation en attente.
      // Objectif : afficher sur la home une liste "Demandes en attente" avec Accept / Refuse.
      if (currentUser!.roles.contains(Role.artist)) {
        _listenToPendingRequests(uid);
      }
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  void _listenToPendingRequests(String artistId) {
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
  /// Lecture one-shot via repository.getShowDateById(dateId),
  /// désormais branchée sur la couche REST (avec fallback transitoire géré dans le repository).
  /// Le cache requestsShowDates évite les rechargements inutiles.
  Future<void> _loadShowDatesForRequests() async {
    for (final booking in pendingRequests) {
      final dateId = booking.dateId;

      // On ignore les bookings incomplets
      if (dateId == null || dateId.isEmpty) continue;

      // Si la date est déjà en cache, pas besoin de la recharger
      if (requestsShowDates.containsKey(dateId)) continue;

      try {
        final showDate = await _showDateRepository.getShowDateById(dateId);
        if (showDate != null) {
          requestsShowDates[dateId] = showDate;
        }
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

      _snackbarService.showSnackbar(
        message: accept
            ? "C'est noté ! Présence confirmée."
            : "C'est noté ! Date refusée.",
        duration: const Duration(seconds: 2),
      );

      // Mise à jour optimiste : on retire immédiatement la demande de la liste.
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

}
