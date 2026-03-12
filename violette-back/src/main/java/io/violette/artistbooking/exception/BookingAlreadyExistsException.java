package io.violette.artistbooking.exception;

/**
 * Exception métier : un booking actif existe déjà pour cet artiste sur cette date.
 * Violation de la contrainte d'unicité {@code UNIQUE(show_date_id, artist_id)}.
 * Mappée en HTTP 409 Conflict par {@link mapper.BookingAlreadyExistsExceptionMapper}.
 */
public class BookingAlreadyExistsException extends RuntimeException {

    public BookingAlreadyExistsException() {
        super("Un booking existe déjà pour cet artiste sur cette date.");
    }

    public BookingAlreadyExistsException(String message) {
        super(message);
    }
}
