import 'package:violette_front/models/enums/booking_status.dart';

class ArtistBooking {
  final String artistId;
  final String? dateId;
  final BookingStatus status;

  ArtistBooking({
    required this.artistId,
    this.dateId,
    required this.status,
  });
}
