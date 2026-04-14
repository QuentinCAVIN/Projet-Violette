package io.violette.showdate.model;

/**
 * Statut de disponibilité d'un artiste pour une date de spectacle.
 *
 * <p>Transitions autorisées (après première saisie, retour à PENDING interdit) :
 * <pre>
 * PENDING    → AVAILABLE | IF_NEEDED | UNAVAILABLE  (première saisie)
 * AVAILABLE  → IF_NEEDED | UNAVAILABLE              (modification)
 * IF_NEEDED  → AVAILABLE | UNAVAILABLE              (modification)
 * UNAVAILABLE → AVAILABLE | IF_NEEDED               (modification)
 * </pre>
 */
public enum AvailabilityStatus {
    /** Aucune réponse de l'artiste — état initial. */
    PENDING,
    /** Artiste disponible et sans condition. */
    AVAILABLE,
    /** Artiste disponible si besoin, mais non prioritaire. */
    IF_NEEDED,
    /** Artiste indisponible. */
    UNAVAILABLE
}
