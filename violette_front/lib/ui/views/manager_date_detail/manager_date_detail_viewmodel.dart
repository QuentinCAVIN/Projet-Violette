import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:violette_front/app/app.locator.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/models/enums/availability_status.dart';
import 'package:violette_front/models/enums/booking_status.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/models/violette_user.dart';
import 'package:violette_front/repositories/booking_repository.dart';
import 'package:violette_front/repositories/show_date_repository.dart';
import 'package:violette_front/repositories/user_repository.dart';

/// ViewModel de l’écran "Détail d’une date" côté gérant.
class ManagerDateDetailViewModel extends BaseViewModel {
  // Services injectés via le locator Stacked
  final _bookingRepository = locator<BookingRepository>();
  final _userRepository = locator<UserRepository>();
  final _showDateRepository = locator<ShowDateRepository>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();

  final ShowDate showDate;

  ManagerDateDetailViewModel({required this.showDate});

  List<VioletteUser> availableArtists = [];

  List<ArtistBooking> bookings = [];

  ShowDate? currentShowDate;

  int get artistsCount =>
      currentShowDate?.artistsCount ?? showDate.artistsCount;

  int get selectedCount =>
      currentShowDate?.selectedCount ?? showDate.selectedCount;

  StreamSubscription<ShowDate>? _showDateSubscription;

  bool get canSendConfirmation =>
      bookings.any((b) => b.status == BookingStatus.selected);

  @override
  void dispose() {
    // Nettoyage de la subscription pour éviter toute fuite mémoire
    _showDateSubscription?.cancel();
    super.dispose();
  }

  /// Méthode d’initialisation appelée à l’ouverture de la vue.
  Future<void> initialize() async {
    setBusy(true);
    _bookingRepository
        .watchBookingsForDate(showDate.uid!)
        .listen((bookingsData) {
      bookings = bookingsData;
      rebuildUi();
    });

    await _loadAllArtists();

    setBusy(false);
  }

  Stream<ShowDate> get showDateStream =>
      _showDateRepository.watchShowDate(showDate.uid!);

  Future<void> _loadAllArtists() async {
    final artistIds = showDate.artistsAvailability.keys.toList();

    availableArtists = [];

    for (final id in artistIds) {
      final user = await _userRepository.getUser(id);
      if (user != null) {
        availableArtists.add(user);
      }
    }
  }

  /// Retourne le booking associé à un artiste pour cette date,
  /// ou null s’il n’existe pas.
  ArtistBooking? getBookingForArtist(String artistId) {
    try {
      return bookings.firstWhere((b) => b.artistId == artistId);
    } catch (_) {
      return null;
    }
  }

  /// Détermine si la checkbox de sélection est activée pour un artiste donné.
  ///
  /// Règles métier :
  /// 1. Si un booking existe :
  ///    - selectable uniquement si status == selected (pour permettre la désélection)
  ///    - bloqué si pending / confirmed / refused
  /// 2. Si aucun booking n’existe :
  ///    - l’artiste doit être "available"
  ///    - le plafond artistsCount ne doit pas être atteint
  bool isSelectionEnabled(ShowDate currentShowDate, String artistId) {
    final booking = getBookingForArtist(artistId);

    // Cas 1 : un booking existe déjà
    if (booking != null) {
      // Autorise uniquement la désélection
      return booking.status == BookingStatus.selected;
    }

    // Cas 2 : tentative de nouvelle sélection
    final availability = currentShowDate.artistsAvailability[artistId];

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

  /// Sélectionne ou désélectionne un artiste.
  Future<void> toggleSelection(String artistId, bool? value) async {
    if (value == null) return;

    try {
      await _bookingRepository.toggleSelection(
        showDate.uid!,
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
    try {
      await _bookingRepository.sendConfirmationRequests(showDate.uid!);

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
