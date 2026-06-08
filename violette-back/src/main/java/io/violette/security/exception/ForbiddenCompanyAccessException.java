package io.violette.security.exception;

/**
 * Exception levée quand le manager authentifié ne peut pas être associé à une compagnie,
 * ou n'a pas les droits suffisants pour accéder à la ressource demandée.
 * Mappée en HTTP 403 Forbidden par {@link io.violette.security.exception.mapper.ForbiddenCompanyAccessExceptionMapper}.
 * Le message exposé est volontairement neutre pour ne pas divulguer l'existence de ressources tierces.
 */
public class ForbiddenCompanyAccessException extends RuntimeException {

    public ForbiddenCompanyAccessException() {
        super("Accès refusé.");
    }

    public ForbiddenCompanyAccessException(String message) {
        super(message);
    }
}
