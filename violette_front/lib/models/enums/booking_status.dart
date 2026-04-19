import 'package:flutter/material.dart';

/// Statut d’une réservation artiste (cycle de vie aligné sur le backend).
enum BookingStatus {
  /// Présélection par le gérant, sans engagement ferme pour l’artiste.
  selected,

  /// Demande envoyée à l’artiste, en attente de réponse.
  pendingConfirmation,

  /// Demande acceptée par l’artiste, engagement confirmé.
  confirmed,

  /// Demande refusée par l’artiste.
  refused;

  String get displayName {
    switch (this) {
      case BookingStatus.selected:
        return 'Présélectionné';
      case BookingStatus.pendingConfirmation:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmé';
      case BookingStatus.refused:
        return 'Refusé';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.selected:
        return Colors.blue;
      case BookingStatus.pendingConfirmation:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.refused:
        return Colors.red;
    }
  }
}

BookingStatus bookingStatusFromString(String value) {
  return BookingStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => BookingStatus.selected,
  );
}
