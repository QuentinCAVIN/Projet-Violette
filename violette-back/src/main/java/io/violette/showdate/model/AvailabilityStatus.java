package io.violette.showdate.model;

/**
 * Statut de disponibilité d'un artiste pour une date de spectacle.
 *
 * <p>Transitions autorisées (après première saisie, retour à PENDING interdit) :
 * <pre>
 * PENDING     → AVAILABLE | CONDITIONAL | UNAVAILABLE  (première saisie)
 * AVAILABLE   → CONDITIONAL | UNAVAILABLE               (modification)
 * CONDITIONAL → AVAILABLE | UNAVAILABLE                 (modification)
 * UNAVAILABLE → AVAILABLE | CONDITIONAL                 (modification)
 * </pre>
 */
public enum AvailabilityStatus {
    /** Aucune réponse de l'artiste — état initial. */
    PENDING,
    /** Artiste disponible et sans condition. */
    AVAILABLE,
    /** Artiste disponible sous conditions (horaires, déplacement, etc.). */
    CONDITIONAL,
    /** Artiste indisponible. */
    UNAVAILABLE
}
