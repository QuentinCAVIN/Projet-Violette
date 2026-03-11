package io.violette.cabaretcompany.exception;

/**
 * Exception métier : compagnie introuvable (id).
 * Mappée en HTTP 404 Not Found par {@link io.violette.cabaretcompany.exception.mapper.CabaretCompanyNotFoundExceptionMapper}.
 */
public class CabaretCompanyNotFoundException extends RuntimeException {

    public CabaretCompanyNotFoundException() {
        super("Compagnie introuvable.");
    }

    public CabaretCompanyNotFoundException(String message) {
        super(message);
    }
}
