import 'package:flutter/material.dart';

/// Représente l’état d’une réservation d’un artiste pour une date.
///
/// Cet enum modélise les différents états d’une réservation :
/// - présélection par le gérant
/// - envoi d’une demande officielle
/// - réponse de l’artiste (acceptation ou refus)
enum BookingStatus {

  /// L’artiste est présélectionné par le gérant.
  ///
  /// Cette étape intervient avant toute demande officielle.
  /// Elle permet de préparer une équipe sans engagement.
  /// L’artiste reste libre et peut être sélectionné sur d’autres dates.
  preselected,

  /// Une demande de confirmation a été envoyée à l’artiste.
  ///
  /// L’artiste doit répondre (accepter ou refuser).
  /// Cette étape correspond à une sollicitation officielle.
  pendingConfirmation,

  /// L’artiste a accepté la demande.
  ///
  /// L’affectation est confirmée et la place est considérée comme prise.
  /// L’artiste devient indisponible pour cette date.
  confirmed,

  /// L’artiste a refusé la demande.
  ///
  /// La place est libérée et peut être proposée à un autre artiste.
  refused;
}



/// Extension pour l’affichage des statuts dans l’interface utilisateur.
extension BookingStatusDisplay on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.preselected:
        return 'Présélectionné';
      case BookingStatus.pendingConfirmation:
        return 'En attente de réponse';
      case BookingStatus.confirmed:
        return 'Confirmé';
      case BookingStatus.refused:
        return 'Refusé';
    }
  }

  /// Couleur associée au statut pour l’UI.
  Color get color {
    switch (this) {
      case BookingStatus.preselected:
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



/// Conversion d’une chaîne de caractères vers un BookingStatus.
///
/// Si la valeur ne correspond à aucun statut connu,
/// le fallback est `preselected` afin d’éviter les erreurs.
BookingStatus bookingStatusFromString(String value) {
  return BookingStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => BookingStatus.preselected,
  );
}