// ignore_for_file: deprecated_member_use_from_same_package

import 'package:violette_front/data/remote/booking_remote_data_source.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/services/booking_service.dart';

import 'booking_repository.dart';

/// Implémentation hybride : REST pour toutes les opérations actives.
///
/// ## REST (actif)
/// - [getBookingsForDate]
/// - [getPendingRequestsForArtist]
/// - [toggleSelection]
/// - [sendConfirmationRequests]
/// - [respondToRequest]
///
/// ## Firestore legacy (déprécié, non appelé en production)
/// - [watchBookingsForDate] → délègue à [FirestoreBookingRepository]
/// - [watchPendingRequestsForArtist] → délègue à [FirestoreBookingRepository]
///
/// Ces deux méthodes ne sont plus appelées par aucun ViewModel actif.
/// Elles subsistent uniquement pour satisfaire le contrat [BookingRepository]
/// en attendant la suppression formelle des streams legacy.
class RestBookingRepository implements BookingRepository {
  RestBookingRepository({
    FirestoreBookingRepository? legacyRepository,
    BookingRemoteDataSource? remoteDataSource,
  })  : _legacy = legacyRepository ?? FirestoreBookingRepository(),
        _remote = remoteDataSource ?? BookingRemoteDataSource();

  final FirestoreBookingRepository _legacy;
  final BookingRemoteDataSource _remote;

  /// @deprecated — délègue à Firestore. Non utilisé en production.
  /// Voir [getBookingsForDate] pour le remplacement REST.
  @override
  @Deprecated(
    'Délègue à Firestore. Utiliser getBookingsForDate à la place.',
  )
  Stream<List<ArtistBooking>> watchBookingsForDate(String dateId) =>
      _legacy.watchBookingsForDate(dateId);

  /// @deprecated — délègue à Firestore. Non utilisé en production.
  /// Voir [getPendingRequestsForArtist] pour le remplacement REST.
  @override
  @Deprecated(
    'Délègue à Firestore. Utiliser getPendingRequestsForArtist à la place.',
  )
  Stream<List<ArtistBooking>> watchPendingRequestsForArtist(String artistId) =>
      _legacy.watchPendingRequestsForArtist(artistId);

  @override
  Future<List<ArtistBooking>> getBookingsForDate(String dateId) =>
      _remote.getBookingsForDate(dateId);

  @override
  Future<List<ArtistBooking>> getPendingRequestsForArtist(String artistId) =>
      _remote.getPendingRequestsForArtist();

  @override
  Future<void> toggleSelection(
    String dateId,
    String artistId,
    bool select,
  ) =>
      _remote.toggleSelection(dateId, artistId, select);

  @override
  Future<void> sendConfirmationRequests(String dateId) =>
      _remote.sendConfirmationRequests(dateId);

  @override
  Future<void> respondToRequest(
    String dateId,
    String artistId,
    bool accept,
  ) =>
      _remote.respondToRequest(dateId, artistId, accept);
}
