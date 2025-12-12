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
        return 'Conditionnel';
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
}

// Ci -dessosu pour les ocnversion Firestore
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

extension AvailabilityStatusFirestoreX on AvailabilityStatus {
  String get firestoreValue {
    switch (this) {
      case AvailabilityStatus.available:
        return 'available';
      case AvailabilityStatus.conditional:
        return 'conditional';
      case AvailabilityStatus.unavailable:
        return 'unavailable';
      case AvailabilityStatus.pending:
        return 'pending';
    }
  }
}
