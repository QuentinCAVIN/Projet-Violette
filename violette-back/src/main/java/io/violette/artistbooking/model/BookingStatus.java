package io.violette.artistbooking.model;

/**
 * Cycle de vie d'une réservation artiste.
 *
 * <p>À ne pas confondre avec la disponibilité :
 * {@code ArtistAvailability} indique si l'artiste peut être sollicité,
 * tandis que {@code BookingStatus} décrit l'état de la réservation
 * une fois le processus de sélection ou de confirmation engagé.
 */
public enum BookingStatus {

    /**
     * Présélection par le gérant, sans engagement pour l'artiste.
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
     * Booking annulé (ex. annulation de la date de spectacle).
     */
    CANCELLED
}