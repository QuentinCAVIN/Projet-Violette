package io.violette.showdate.exception;

/**
 * Exception métier : l'artiste possède un booking {@code CONFIRMED} sur cette date
 * et ne peut plus modifier sa disponibilité.
 * Mappée en HTTP 409 Conflict par {@link io.violette.showdate.exception.mapper.AvailabilityLockedByConfirmedBookingExceptionMapper}.
 */
public class AvailabilityLockedByConfirmedBookingException extends RuntimeException {

    public AvailabilityLockedByConfirmedBookingException() {
        super("Disponibilité verrouillée : un engagement ferme existe sur cette date.");
    }
}
