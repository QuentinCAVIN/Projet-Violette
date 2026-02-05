import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:violette_front/models/enums/booking_status.dart';

class ArtistBooking {
  final String artistId;
  final String? dateId; 
  final BookingStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? requestedAt;
  final DateTime? respondedAt;

  ArtistBooking({
    required this.artistId,
    this.dateId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.requestedAt,
    this.respondedAt,
  });

  factory ArtistBooking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    
    String? resolvedDateId = data?['dateId'];
    if (resolvedDateId == null && snapshot.reference.parent.parent != null) {
       resolvedDateId = snapshot.reference.parent.parent!.id;
    }

    return ArtistBooking(
      artistId: data?['artistId'] ?? '',
      dateId: resolvedDateId,
      status: bookingStatusFromString(data?['status'] ?? 'selected'),
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate(),
      requestedAt: (data?['requestedAt'] as Timestamp?)?.toDate(),
      respondedAt: (data?['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "artistId": artistId,
      if (dateId != null) "dateId": dateId,  
      "status": status.name,
      if (createdAt != null) "createdAt": createdAt,
      if (updatedAt != null) "updatedAt": updatedAt,
      if (requestedAt != null) "requestedAt": requestedAt,
      if (respondedAt != null) "respondedAt": respondedAt,
    };
  }
}
