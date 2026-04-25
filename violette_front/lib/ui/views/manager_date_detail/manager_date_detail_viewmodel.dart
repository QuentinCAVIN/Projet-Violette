import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/availability.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/models/manager_artist_line.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/repositories/availability_repository.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/user_repository.dart';

/// ViewModel de l'écran "Détail d'une date" côté gérant.
class ManagerDateDetailViewModel extends BaseViewModel {
  final _bookingRepository = locator<BookingRepository>();
  final _userRepository = locator<UserRepository>();
  final _availabilityRepository = locator<AvailabilityRepository>();
  final _showDateRepository = locator<ShowDateRepository>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();

  final ShowDate showDate;

  ManagerDateDetailViewModel({required this.showDate});

  /// Lignes affichées : profil + identifiant artiste backend (aligné API booking).
  List<ManagerArtistLine> artistLines = [];

  List<ArtistBooking> bookings = [];
  List<Availability> availabilities = [];

  ShowDate? currentShowDate;

  int get artistsCount =>
      currentShowDate?.totalRequiredArtists ?? showDate.totalRequiredArtists;

  int get selectedCount =>
      currentShowDate?.selectedCount ?? showDate.selectedCount;

  bool get canSendConfirmation =>
      displayedShowDate.status == ShowDateStatus.confirmed &&
      bookings.any((b) => b.status == BookingStatus.preselected);

  /// Méthode d'initialisation appelée à l'ouverture de la vue.
  Future<void> initialize() async {
    setBusy(true);

    final dateId = showDate.id;
    if (dateId.isEmpty) {
      currentShowDate = showDate;
      availabilities = [];
      artistLines = [];
      bookings = [];
      setBusy(false);
      return;
    }

    currentShowDate = showDate;

    await refreshShowDateDetail();
    await _loadAvailabilities();
    await _loadAllArtists();
    await _loadBookings(dateId);

    setBusy(false);
  }

  ShowDate get displayedShowDate => currentShowDate ?? showDate;

  /// Recharge manuellement le détail de la date via REST.
  Future<void> refreshShowDateDetail() async {
    final dateId = showDate.id;
    if (dateId.isEmpty) {
      currentShowDate = showDate;
      rebuildUi();
      return;
    }

    await _loadShowDateDetail(dateId);
    rebuildUi();
  }

  Future<void> _loadShowDateDetail(String dateId) async {
    try {
      final loaded = await _showDateRepository.getShowDateById(dateId);
      if (loaded == null) {
        return;
      }
      currentShowDate = loaded;
    } catch (_) {
      // On conserve le fallback sur la date de navigation pour éviter un crash UI.
      currentShowDate = currentShowDate ?? showDate;
      _snackbarService.showSnackbar(
        message: "Impossible de charger le détail de la date.",
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Charge les bookings depuis le backend (one-shot REST).
  ///
  /// Appelé à l'initialisation et après chaque mutation réussie.
  Future<void> _loadBookings(String dateId) async {
    try {
      bookings = await _bookingRepository.getBookingsForDate(dateId);
    } catch (_) {
      bookings = [];
      _snackbarService.showSnackbar(
        message: "Impossible de charger les réservations.",
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _loadAvailabilities() async {
    final dateId =
        displayedShowDate.id.isNotEmpty ? displayedShowDate.id : showDate.id;
    if (dateId.isEmpty) {
      availabilities = [];
      return;
    }

    try {
      availabilities = await _availabilityRepository.getAvailabilitiesForDate(
        dateId,
      );
    } catch (_) {
      availabilities = [];
      _snackbarService.showSnackbar(
        message: "Impossible de charger les disponibilités.",
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _loadAllArtists() async {
    artistLines = [];

    for (final availability in availabilities) {
      final user = await _userRepository.getUser(availability.artistId);
      if (user != null) {
        artistLines.add(
          ManagerArtistLine(
            user: user,
            apiArtistId: availability.artistId,
          ),
        );
      }
    }
  }

  /// Rafraîchit l'état de l'écran après une mutation booking REST.
  ///
  /// Recharge les bookings et le détail de la date (selectedCount) puis
  /// reconstruit le widget.
  Future<void> _refreshAfterAction() async {
    final dateId =
        displayedShowDate.id.isNotEmpty ? displayedShowDate.id : showDate.id;
    if (dateId.isEmpty) return;

    await Future.wait([
      _loadBookings(dateId),
      _loadShowDateDetail(dateId),
    ]);
    rebuildUi();
  }

  /// Retourne le booking associé à un artiste pour cette date,
  /// ou null s'il n'existe pas.
  ///
  /// [apiArtistId] est l'identifiant backend (disponibilités). Les documents
  /// Firestore legacy peuvent encore référencer le `firebaseUid` : on teste
  /// les deux lorsque la ligne est connue.
  ArtistBooking? getBookingForArtist(String apiArtistId) {
    String? firebaseUid;
    for (final line in artistLines) {
      if (line.apiArtistId == apiArtistId) {
        firebaseUid = line.user.uid;
        break;
      }
    }
    try {
      return bookings.firstWhere(
        (b) =>
            b.artistId == apiArtistId ||
            (firebaseUid != null && b.artistId == firebaseUid),
      );
    } catch (_) {
      return null;
    }
  }

  /// État visuel de la case à cocher (cohérent avec le statut de réservation).
  ///
  /// Refus : décochée. Sinon (sélectionné, en attente de réponse, confirmé) : cochée.
  bool isBookingCheckboxChecked(ArtistBooking? booking) {
    if (booking == null) return false;
    return booking.status != BookingStatus.refused &&
        booking.status != BookingStatus.cancelled;
  }

  /// Détermine si la checkbox de sélection est activée pour un artiste donné.
  ///
  /// Règles métier :
  /// 1. Si un booking existe :
  ///    - activée uniquement si status == selected (pour permettre la désélection)
  ///    - bloqué si pending / confirmed / refused
  /// 2. Si aucun booking n'existe :
  ///    - la date doit être en [ShowDateStatus.option] ou [ShowDateStatus.confirmed]
  ///      (pas inquiry / staffed / cancelled / archived)
  ///    - l'artiste doit être "available"
  ///    - le plafond `totalRequiredArtists` ne doit pas être atteint
  bool isSelectionEnabled(ShowDate currentShowDate, String artistId) {
    final booking = getBookingForArtist(artistId);

    if (booking != null) {
      return booking.status == BookingStatus.preselected;
    }

    if (!_allowsNewArtistSelectionForShowDateStatus(currentShowDate.status)) {
      return false;
    }

    final availability = getAvailabilityForArtist(artistId);

    if (availability != AvailabilityStatus.available) {
      return false;
    }

    // Quand aucun besoin n'est encore configuré (0), on n'applique pas
    // de plafond bloquant côté UI pour ne pas bloquer le gérant dans sa réservation
    //TODO : Que se passe t il si le plafond est congiguré avec un montant inférieur
    // au nombre d'artistes sélectionnés ? 
    if (currentShowDate.totalRequiredArtists > 0 &&
        currentShowDate.selectedCount >= currentShowDate.totalRequiredArtists) {
      return false;
    }

    return true;
  }

  static bool _allowsNewArtistSelectionForShowDateStatus(ShowDateStatus status) {
    return status == ShowDateStatus.option || status == ShowDateStatus.confirmed;
  }

  AvailabilityStatus? getAvailabilityForArtist(String artistId) {
    for (final availability in availabilities) {
      if (availability.artistId == artistId) {
        return availability.status;
      }
    }
    return null;
  }

  /// Sélectionne ou désélectionne un artiste.
  ///
  /// Après la mutation REST, l'écran est rechargé via [_refreshAfterAction].
  Future<void> toggleSelection(String artistId, bool? value) async {
    if (value == null) return;
    final dateId =
        displayedShowDate.id.isNotEmpty ? displayedShowDate.id : showDate.id;
    if (dateId.isEmpty) {
      _snackbarService.showSnackbar(
        message: "Identifiant de date manquant.",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      await _bookingRepository.toggleSelection(
        dateId,
        artistId,
        value,
      );
      await _refreshAfterAction();
    } catch (e) {
      _dialogService.showDialog(
        title: 'Erreur',
        description: e.toString(),
      );
    }
  }

  /// Envoie les demandes de confirmation aux artistes sélectionnés.
  ///
  /// Après l'envoi REST, l'écran est rechargé via [_refreshAfterAction].
  Future<void> sendConfirmation() async {
    final dateId =
        displayedShowDate.id.isNotEmpty ? displayedShowDate.id : showDate.id;
    if (dateId.isEmpty) {
      _snackbarService.showSnackbar(
        message: "Identifiant de date manquant.",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (displayedShowDate.status != ShowDateStatus.confirmed) {
      _dialogService.showDialog(
        title: 'Envoi impossible',
        description:
            "Passe d'abord la date au statut Confirmé avant d'envoyer les demandes.",
      );
      return;
    }

    try {
      await _bookingRepository.sendConfirmationRequests(dateId);
      await _refreshAfterAction();

      _snackbarService.showSnackbar(
        message: "Demandes envoyées !",
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _dialogService.showDialog(
        title: 'Erreur',
        description: "Échec de l'envoi : $e",
      );
    }
  }

  List<ShowDateStatus> getAvailableNextStatuses() {
    switch (displayedShowDate.status) {
      case ShowDateStatus.inquiry:
        return const [ShowDateStatus.option];
      case ShowDateStatus.option:
        return const [ShowDateStatus.confirmed];
      case ShowDateStatus.confirmed:
        return const [ShowDateStatus.staffed];
      case ShowDateStatus.staffed:
      case ShowDateStatus.cancelled:
      case ShowDateStatus.archived:
        return const [];
    }
  }

  Future<void> changeShowDateStatus(ShowDateStatus targetStatus) async {
    final dateId =
        displayedShowDate.id.isNotEmpty ? displayedShowDate.id : showDate.id;
    if (dateId.isEmpty) {
      _snackbarService.showSnackbar(
        message: "Identifiant de date manquant.",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      await _showDateRepository.updateShowDateStatus(dateId, targetStatus);
      await _refreshAfterAction();
      await _loadAvailabilities();
      await _loadAllArtists();
      rebuildUi();
      _snackbarService.showSnackbar(
        message: "Statut mis à jour : ${targetStatus.label}.",
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Changement de statut impossible',
        description: e.toString(),
      );
    }
  }
}
