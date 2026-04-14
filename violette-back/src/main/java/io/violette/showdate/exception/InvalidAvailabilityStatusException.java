package io.violette.showdate.exception;

/**
 * Exception métier : statut de disponibilité non autorisé pour la requête (ex. PENDING explicite).
 * Mappée en HTTP 400 Bad Request par {@link io.violette.showdate.exception.mapper.InvalidAvailabilityStatusExceptionMapper}.
 */
public class InvalidAvailabilityStatusException extends RuntimeException {

    public InvalidAvailabilityStatusException(String message) {
        super(message);
    }
}
