package io.violette.showdate.model;

/**
 * Statut du cycle de vie d'une date de spectacle.
 *
 * <p>Transitions autorisées :
 * <pre>
 * INQUIRY  → OPTION    (besoins qualifiés, devis envoyé, option posée)
 * INQUIRY  → CANCELLED (demande abandonnée en phase de qualification)
 * OPTION   → CONFIRMED (client valide le devis / la prestation)
 * OPTION   → CANCELLED (client refuse / annulation avant confirmation)
 * CONFIRMED → STAFFED  (effectif artistique complet et confirmé)
 * CONFIRMED → CANCELLED
 * STAFFED  → CANCELLED (annulation exceptionnelle d'une date verrouillée)
 * CONFIRMED | STAFFED → ARCHIVED (prestation passée, historisée)
 * </pre>
 *
 * <p>Remarque : une {@code ShowDate} en {@code INQUIRY} peut être incomplète
 * (date calendrier, type de spectacle, nombre d'artistes non encore définis).
 */
public enum ShowDateStatus {
    /** Demande client reçue — besoin en cours de qualification ; la date peut être incomplète. */
    INQUIRY,
    /** Besoins cadrés, devis envoyé — date ouverte à la sélection/réservation d'artistes. */
    OPTION,
    /** Devis confirmé par le client. */
    CONFIRMED,
    /** Effectif artistique complet et sécurisé — aucune modification de l'équipe possible. */
    STAFFED,
    /** Date annulée (demande abandonnée, devis refusé, annulation client, etc.). */
    CANCELLED,
    /** Prestation passée, conservée dans l'historique. */
    ARCHIVED
}
