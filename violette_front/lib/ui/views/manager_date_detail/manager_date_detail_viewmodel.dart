import 'dart:async';
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
import 'package:violette_front/models/violette_user.dart';
import 'package:violette_front/repositories/availability_repository.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/user_repository.dart';

/// ViewModel de l’écran "Détail d’une date" côté gérant.
class ManagerDateDetailViewModel extends BaseViewModel {
  // Services injectés via le locator Stacked
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
      currentShowDate?.artistsCount ?? showDate.artistsCount;

  int get selectedCount =>
      currentShowDate?.selectedCount ?? showDate.selectedCount;

  StreamSubscription<List<ArtistBooking>>? _bookingSubscription;

  bool get canSendConfirmation =>
      bookings.any((b) => b.status == BookingStatus.selected);

  @override
  void dispose() {
    // Nettoyage des subscriptions pour éviter toute fuite mémoire.
    _bookingSubscription?.cancel();
    super.dispose();
  }

  /// Méthode d’initialisation appelée à l’ouverture de la vue.
  Future<void> initialize() async {
    setBusy(true);

    final dateId = showDate.uid;
    if (dateId == null || dateId.isEmpty) {
      currentShowDate = showDate;
      availabilities = [];
      artistLines = [];
      bookings = [];
      setBusy(false);
      return;
    }

    currentShowDate = showDate;

    _bookingSubscription =
        _bookingRepository.watchBookingsForDate(dateId).listen((bookingsData) {
      bookings = bookingsData;
      rebuildUi();
    });

    await refreshShowDateDetail();

    await _loadAvailabilities();
    await _loadAllArtists();

    setBusy(false);
  }

  ShowDate get displayedShowDate => currentShowDate ?? showDate;

  /// Recharge manuellement le détail de la date via REST.
  Future<void> refreshShowDateDetail() async {
    final dateId = showDate.uid;
    if (dateId == null || dateId.isEmpty) {
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

  Future<void> _loadAvailabilities() async {
    final dateId = displayedShowDate.uid ?? showDate.uid;
    if (dateId == null || dateId.isEmpty) {
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

  /// Retourne le booking associé à un artiste pour cette date,
  /// ou null s’il n’existe pas.
  ///
  /// [apiArtistId] est l’identifiant backend (disponibilités). Les documents
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
    return booking.status != BookingStatus.refused;
  }

  /// Détermine si la checkbox de sélection est activée pour un artiste donné.
  ///
  /// Règles métier :
  /// 1. Si un booking existe :
  ///    - activée uniquement si status == selected (pour permettre la désélection)
  ///    - bloqué si pending / confirmed / refused
  /// 2. Si aucun booking n’existe :
  ///    - la date doit être en [ShowDateStatus.option] ou [ShowDateStatus.confirmed]
  ///      (pas inquiry / staffed / cancelled / archived)
  ///    - l’artiste doit être "available"
  ///    - le plafond artistsCount ne doit pas être atteint
  bool isSelectionEnabled(ShowDate currentShowDate, String artistId) {
    final booking = getBookingForArtist(artistId);

    // Cas 1 : un booking existe déjà
    if (booking != null) {
      // Autorise uniquement la désélection
      return booking.status == BookingStatus.selected;
    }

    // Cas 2 : tentative de nouvelle sélection — garde sur le cycle de vie de la date
    if (!_allowsNewArtistSelectionForShowDateStatus(currentShowDate.status)) {
      return false;
    }

    final availability = getAvailabilityForArtist(artistId);

    // Sélection autorisée uniquement pour les artistes disponibles
    if (availability != AvailabilityStatus.available) {
      return false;
    }

    // Vérification du plafond
    if (currentShowDate.selectedCount >= currentShowDate.artistsCount) {
      return false;
    }

    return true;
  }

  /// Nouvelle présélection / réservation : uniquement tant que la date est ouverte
  /// côté commercial (option ou confirmée client).
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
  Future<void> toggleSelection(String artistId, bool? value) async {
    if (value == null) return;
    final dateId = displayedShowDate.uid ?? showDate.uid;
    if (dateId == null || dateId.isEmpty) {
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
    } catch (e) {
      _dialogService.showDialog(
        title: 'Erreur',
        description: e.toString(),
      );
    }
  }

  /// Envoie les demandes de confirmation aux artistes sélectionnés.
  Future<void> sendConfirmation() async {
    final dateId = displayedShowDate.uid ?? showDate.uid;
    if (dateId == null || dateId.isEmpty) {
      _snackbarService.showSnackbar(
        message: "Identifiant de date manquant.",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      await _bookingRepository.sendConfirmationRequests(dateId);

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
}
