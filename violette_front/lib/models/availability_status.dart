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
