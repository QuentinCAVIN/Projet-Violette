package io.violette.showdate.exception;

/**
 * Exception métier : date de spectacle introuvable (id).
 * Mappée en HTTP 404 Not Found par {@link io.violette.showdate.exception.mapper.ShowDateNotFoundExceptionMapper}.
 */
public class ShowDateNotFoundException extends RuntimeException {

    public ShowDateNotFoundException() {
        super("Date de spectacle introuvable.");
    }

    public ShowDateNotFoundException(String message) {
        super(message);
    }
}
