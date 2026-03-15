package io.violette.cabaretcompany.exception;

/**
 * Exception métier : revue introuvable (id).
 * Mappée en HTTP 404 Not Found par {@link io.violette.cabaretcompany.exception.mapper.CabaretShowNotFoundExceptionMapper}.
 */
public class CabaretShowNotFoundException extends RuntimeException {

    public CabaretShowNotFoundException() {
        super("Revue introuvable.");
    }

    public CabaretShowNotFoundException(String message) {
        super(message);
    }
}
