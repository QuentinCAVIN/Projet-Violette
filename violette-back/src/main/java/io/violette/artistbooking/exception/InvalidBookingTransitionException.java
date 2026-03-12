package io.violette.artistbooking.exception;

/**
 * Exception métier : la transition de statut demandée n'est pas autorisée.
 * Exemples :
 * <ul>
 *   <li>Répondre à un booking déjà {@code CONFIRMED} ou {@code REFUSED}</li>
 *   <li>Désélectionner un booking qui n'est plus {@code SELECTED}</li>
 * </ul>
 * Mappée en HTTP 409 Conflict par {@link mapper.InvalidBookingTransitionExceptionMapper}.
 */
public class InvalidBookingTransitionException extends RuntimeException {

    public InvalidBookingTransitionException() {
        super("Cette transition de statut n'est pas autorisée pour ce booking.");
    }

    public InvalidBookingTransitionException(String message) {
        super(message);
    }
}
