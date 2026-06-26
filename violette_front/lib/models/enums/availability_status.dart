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
        return const Color(0xFF2E7D32);
      case AvailabilityStatus.ifNeeded:
        return const Color(0xFFE65100);
      case AvailabilityStatus.unavailable:
        return const Color(0xFFC62828);
      case AvailabilityStatus.pending:
        return const Color(0xFF616161);
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
