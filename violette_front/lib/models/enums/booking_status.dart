import 'package:flutter/material.dart';

enum BookingStatus {
  selected,
  pendingConfirmation,
  confirmed,
  refused;

  String get displayName {
    switch (this) {
      case BookingStatus.selected:
        return 'Sélectionné';
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
