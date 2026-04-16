import 'package:violette_front/models/enums/availability_status.dart';

/// Modèle domaine pour une disponibilité artiste sur une date donnée.
class Availability {
  final String artistId;
  final AvailabilityStatus status;

  Availability({
    required this.artistId,
    required this.status,
  });
}

