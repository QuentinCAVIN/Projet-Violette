import 'package:flutter/material.dart';

// TODO Deamander à Elodie les différents status qu'elle attends et à quelle moment elle contact les artistes pour proposer une date et a quelle moment du processus elle entrerait la date dans l'application.

enum ShowDateStatus {
  
  pending(label: 'En attente', color: Color(0xFFFFAB00)), // ou utiliser quoteRequest(label: 'Client en attente du devis', color: Color(0xFFFFAB00)), // = le client à fait une demande de devis
  optional(label: 'Option', color: Color(0xFFFFAB00)), // = le devis envoyé au client / la date est ouverte pour les artistes
  confirmed(label: 'Confirmé', color: Color(0xFF00C853)), // = le devis confirmé par le client
  cancelled(label: 'Annulé', color: Color(0xFFD50000)), // = date annulée / devis refusé
  locked(label: 'Vérouillé', color: Color(0xFFD50000)); // = Le nombre adéquate d'artiste est réservé.

  final String label;
  final Color color;

  const ShowDateStatus({
    required this.label,
    required this.color,
  });
}

ShowDateStatus showDateStatusFromString(String value) {
  return ShowDateStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ShowDateStatus.pending,
  );
}
