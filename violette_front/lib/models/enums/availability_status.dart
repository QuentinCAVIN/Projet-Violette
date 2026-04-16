import 'package:flutter/material.dart';

enum AvailabilityStatus {
  available,
  ifNeeded,
  unavailable,
  pending,
}

extension AvailabilityStatusX on AvailabilityStatus {
  String get label {
    switch (this) {
      case AvailabilityStatus.available:
        return 'Disponible';
      case AvailabilityStatus.ifNeeded:
        return 'Si besoin';
      case AvailabilityStatus.unavailable:
        return 'Indisponible';
      case AvailabilityStatus.pending:
        return 'En attente';
    }
  }

  Color get color {
    switch (this) {
      case AvailabilityStatus.available:
        return Colors.green;
      case AvailabilityStatus.ifNeeded:
        return Colors.orange;
      case AvailabilityStatus.unavailable:
        return Colors.red;
      case AvailabilityStatus.pending:
        return Colors.grey;
    }
  }

  // Utilisé pour le changement de statut au second tap sur le calendrier.
  AvailabilityStatus get next {
    switch (this) {
      case AvailabilityStatus.pending:
        return AvailabilityStatus.available;
      case AvailabilityStatus.available:
        return AvailabilityStatus.ifNeeded;
      case AvailabilityStatus.ifNeeded:
        return AvailabilityStatus.unavailable;
      case AvailabilityStatus.unavailable:
        return AvailabilityStatus.available;
    }
  }
}

//Pour faciliter les conversions vers Firestore
AvailabilityStatus availabilityStatusFromString(String value) {
  switch (value) {
    case 'available':
      return AvailabilityStatus.available;
    case 'ifNeeded':
      return AvailabilityStatus.ifNeeded;
    case 'unavailable':
      return AvailabilityStatus.unavailable;
    case 'pending':
    default:
      return AvailabilityStatus.pending;
  }
}
