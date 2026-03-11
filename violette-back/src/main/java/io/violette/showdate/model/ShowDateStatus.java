package io.violette.showdate.model;

/**
 * Statut du cycle de vie d'une date de spectacle.
 *
 * <p>Transitions autorisées :
 * <pre>
 * PENDING → OPTIONAL   (devis envoyé, date ouverte aux artistes)
 * OPTIONAL → CONFIRMED (client confirme la date)
 * OPTIONAL → CANCELLED (client refuse / annulation avant confirmation)
 * CONFIRMED → LOCKED   (effectif artistique complet et confirmé)
 * CONFIRMED → CANCELLED
 * LOCKED → CANCELLED   (annulation exceptionnelle d'une date verrouillée)
 * </pre>
 */
public enum ShowDateStatus {
    /** Créée, en attente d'envoi de devis. */
    PENDING,
    /** Devis envoyé, date ouverte aux déclarations de disponibilité artistes. */
    OPTIONAL,
    /** Devis confirmé par le client. */
    CONFIRMED,
    /** Effectif artistique complet et confirmé — aucune modification possible. */
    LOCKED,
    /** Date annulée. */
    CANCELLED
}
