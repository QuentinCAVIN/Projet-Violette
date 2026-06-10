package io.violette.artistbooking.exception;

/**
 * Exception levée quand l'artiste authentifié tente d'agir sur un booking qui ne lui appartient pas.
 * Mappée en HTTP 403 Forbidden par {@link io.violette.artistbooking.exception.mapper.ForbiddenBookingAccessExceptionMapper}.
 * Le message exposé est volontairement neutre pour ne pas divulguer l'existence de ressources tierces.
 */
public class ForbiddenBookingAccessException extends RuntimeException {

    public ForbiddenBookingAccessException() {
        super("Accès refusé.");
    }

    public ForbiddenBookingAccessException(String message) {
        super(message);
    }
}
