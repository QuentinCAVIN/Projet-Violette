import 'package:violette_front/models/enums/availability_status.dart';

/// Modèle domaine pour une disponibilité artiste sur une date donnée.
class Availability {
  final String artistId;
  final String? artistFirebaseUid;
  final AvailabilityStatus status;

  Availability({
    required this.artistId,
    this.artistFirebaseUid,
    required this.status,
  });
}

