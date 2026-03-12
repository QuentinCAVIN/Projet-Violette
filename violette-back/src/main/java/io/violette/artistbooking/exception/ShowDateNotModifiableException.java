package io.violette.artistbooking.exception;

/**
 * Exception métier : la date de spectacle ne peut plus être modifiée.
 * Levée quand {@code ShowDate.status} est {@code LOCKED} ou {@code CANCELLED}.
 * Toute création, modification ou suppression de booking est bloquée dans cet état.
 * Mappée en HTTP 409 Conflict par {@link mapper.ShowDateNotModifiableExceptionMapper}.
 */
public class ShowDateNotModifiableException extends RuntimeException {

    public ShowDateNotModifiableException() {
        super("La date de spectacle est verrouillée ou annulée. Aucune modification de booking n'est autorisée.");
    }

    public ShowDateNotModifiableException(String message) {
        super(message);
    }
}
