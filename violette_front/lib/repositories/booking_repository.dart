import 'package:violette_front/models/artist_booking.dart';

abstract class BookingRepository {
  Stream<List<ArtistBooking>> watchBookingsForDate(String dateId);
  Stream<List<ArtistBooking>> watchPendingRequestsForArtist(String artistId);

  Future<void> toggleSelection(String dateId, String artistId, bool select);
  Future<void> sendConfirmationRequests(String dateId);
  Future<void> respondToRequest(String dateId, String artistId, bool accept);
}
