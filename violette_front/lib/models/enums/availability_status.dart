import 'package:flutter/material.dart';

enum AvailabilityStatus {
  available,
  conditional,
  unavailable,
  pending,
}

extension AvailabilityStatusX on AvailabilityStatus {
  String get label {
    switch (this) {
      case AvailabilityStatus.available:
        return 'Disponible';
      case AvailabilityStatus.conditional:
        return 'Incertain';
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
      case AvailabilityStatus.conditional:
        return Colors.orange;
      case AvailabilityStatus.unavailable:
        return Colors.red;
      case AvailabilityStatus.pending:
        return Colors.grey;
    }
  }

  // Utilisé pour le changement de satut onTapped sur le TableCalendar
  AvailabilityStatus get next {
    switch (this) {
      case AvailabilityStatus.pending:
        return AvailabilityStatus.available;
      case AvailabilityStatus.available:
        return AvailabilityStatus.conditional;
      case AvailabilityStatus.conditional:
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
    case 'conditional':
      return AvailabilityStatus.conditional;
    case 'unavailable':
      return AvailabilityStatus.unavailable;
    case 'pending':
    default:
      return AvailabilityStatus.pending;
  }
}
