import 'package:flutter/material.dart';

/// Statut principal du cycle de vie d'une date de spectacle.
///
/// Décision V1 :
/// - on conserve un seul objet `ShowDate`, même s'il peut être incomplet
///   dans les premiers stades du processus métier ;
/// - une vraie séparation `ShowOpportunity` / `ShowDate` pourra être étudiée
///   en V2 si le besoin commercial amont devient trop important.
///
/// Remarque importante :
/// - `inquiry` correspond à une demande client / un besoin à qualifier ;
/// - à ce stade, la date calendrier, le type de spectacle, ou le nombre
///   d'artistes peuvent encore être inconnus ;
/// - une `ShowDate` en `inquiry` ne devrait pas forcément apparaître dans
///   le calendrier principal tant qu'elle n'est pas suffisamment qualifiée.
///
/// TODO V2 :
/// prévoir un statut spécifique de type `postponed` / "date reportée"
/// pour les cas de force majeure (ex. décès, tempête, événement exceptionnel)
/// où la date initiale ne peut pas avoir lieu, mais où le client reste engagé
/// et la prestation doit être reprogrammée ultérieurement.
enum ShowDateStatus {
  inquiry(
    label: 'Demande client',
    color: Color(0xFF9E9E9E),
  ), // = le client a pris contact ; le besoin est en cours de qualification ; la date peut encore être incomplète

  option(
    label: 'Option',
    color: Color(0xFFFFAB00),
  ), // = les besoins sont suffisamment cadrés pour envoyer un devis et poser une option ; la date peut être ouverte à la préparation

  confirmed(
    label: 'Confirmée',
    color: Color(0xFF00C853),
  ), // = le client a validé le devis / la prestation

  staffed(
    label: 'Équipe complète',
    color: Color(0xFF2962FF),
  ), // = le nombre requis d'artistes est sécurisé / réservé

  cancelled(
    label: 'Annulée',
    color: Color(0xFFD50000),
  ), // = la demande ou la date est abandonnée (devis refusé, annulation client, etc.)

  archived(
    label: 'Archivée',
    color: Color(0xFF607D8B),
  ); // = la prestation est passée et conservée dans l'historique

  final String label;
  final Color color;

  const ShowDateStatus({
    required this.label,
    required this.color,
  });
}

ShowDateStatus showDateStatusFromString(String value) {
  final normalized = value.trim().toLowerCase();
  return ShowDateStatus.values.firstWhere(
    (e) => e.name == normalized,
    orElse: () => ShowDateStatus.inquiry,
  );
}
