import 'package:flutter/material.dart';

// Énumération pour les différents statuts de disponibilité.
// Cela rend le widget plus robuste et facile à utiliser que de passer des chaînes de caractères.
enum AvailabilityStatus { confirmed, pending, conditional, declined }

class AvailabilityStatusChip extends StatelessWidget {
  final AvailabilityStatus status;

  const AvailabilityStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Récupère les propriétés (label, couleurs) en fonction du statut.
    final (label, backgroundColor, textColor) = _getStatusProperties(context, status);

    // Utilise un Tooltip pour l'accessibilité. Il affiche le label en entier
    // lors d'un appui long ou d'un survol.
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          // Utilise une forme de "stade" pour les bords arrondis.
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .labelMedium // Utilise un style de texte approprié du thème.
              ?.copyWith(color: textColor, letterSpacing: 1.1),
        ),
      ),
    );
  }

  /// Fonction helper privée pour mapper un statut à ses propriétés visuelles.
  /// Note : Les couleurs de succès et d'avertissement pourraient être ajoutées
  /// au ThemeData via des extensions pour une meilleure cohérence.
  (String, Color, Color) _getStatusProperties(BuildContext context, AvailabilityStatus status) {
    final theme = Theme.of(context);
    switch (status) {
      case AvailabilityStatus.confirmed:
        return ('Confirmé', const Color(0xFF4CAF50), Colors.white);
      case AvailabilityStatus.pending:
        return ('En attente', theme.colorScheme.onSurfaceVariant.withOpacity(0.3), theme.colorScheme.onSurface);
      case AvailabilityStatus.conditional:
        return ('Conditionnel', const Color(0xFFFFCA28), Colors.black);
      case AvailabilityStatus.declined:
        return ('Refusé', theme.colorScheme.error, Colors.white);
    }
  }
}
