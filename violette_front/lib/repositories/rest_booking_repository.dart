import 'package:violette_front/data/remote/booking_remote_data_source.dart';
import 'package:violette_front/models/artist_booking.dart';

import 'booking_repository.dart';

/// Implémentation REST des réservations artistes.
class RestBookingRepository implements BookingRepository {
  RestBookingRepository({
    BookingRemoteDataSource? remoteDataSource,
  }) : _remote = remoteDataSource ?? BookingRemoteDataSource();

  final BookingRemoteDataSource _remote;

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
