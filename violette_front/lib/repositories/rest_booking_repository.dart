import 'package:violette_front/data/remote/booking_remote_data_source.dart';
import 'package:violette_front/models/artist_booking.dart';
import 'package:violette_front/services/booking_service.dart';

import 'booking_repository.dart';

/// Implémentation hybride : REST pour les lectures et actions migrées.
///
/// REST : [getBookingsForDate], [getPendingRequestsForArtist], [respondToRequest],
/// [sendConfirmationRequests], [toggleSelection].
/// Firestore : [watchBookingsForDate], [watchPendingRequestsForArtist] (héritage).
class RestBookingRepository implements BookingRepository {
  RestBookingRepository({
    FirestoreBookingRepository? legacyRepository,
    BookingRemoteDataSource? remoteDataSource,
  })  : _legacy = legacyRepository ?? FirestoreBookingRepository(),
        _remote = remoteDataSource ?? BookingRemoteDataSource();

  final FirestoreBookingRepository _legacy;
  final BookingRemoteDataSource _remote;

  @override
  Stream<List<ArtistBooking>> watchBookingsForDate(String dateId) =>
      _legacy.watchBookingsForDate(dateId);

  @override
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
