package io.violette.artistbooking.model;

/**
 * Cycle de vie d'une réservation artiste.
 *
 * <p>La disponibilité de l'artiste sur une date relève d'{@code ArtistAvailability} ;
 * ce statut décrit l'état du <em>booking</em> une fois le gérant et l'artiste engagés
 * dans le processus de réservation.
 */
public enum BookingStatus {

    /**
     * Présélection par le gérant, sans engagement ferme pour l'artiste.
     */
    SELECTED,

    /**
     * Demande envoyée à l'artiste, en attente de réponse.
     */
    PENDING_CONFIRMATION,

    /**
     * Demande acceptée par l'artiste, engagement confirmé.
     */
    CONFIRMED,

    /**
     * Demande refusée par l'artiste.
     */
    REFUSED,

    /**
     * Booking annulé suite à l'annulation de la date de spectacle.
     */
    CANCELLED
}
