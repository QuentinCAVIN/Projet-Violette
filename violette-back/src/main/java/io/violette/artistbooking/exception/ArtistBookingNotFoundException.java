package io.violette.artistbooking.exception;

/**
 * Exception métier : booking artiste introuvable (id).
 * Mappée en HTTP 404 Not Found par {@link mapper.ArtistBookingNotFoundExceptionMapper}.
 */
public class ArtistBookingNotFoundException extends RuntimeException {

    public ArtistBookingNotFoundException() {
        super("Réservation artiste introuvable.");
    }

    public ArtistBookingNotFoundException(String message) {
        super(message);
    }
}
