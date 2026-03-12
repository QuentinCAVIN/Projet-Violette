package io.violette.artistbooking.exception;

/**
 * Exception métier : la date de spectacle n'est pas dans un état compatible avec l'opération demandée.
 *
 * <p>Levée dans deux contextes :
 * <ul>
 *   <li><b>Création de booking / envoi de confirmations</b> : la date doit être {@code CONFIRMED}
 *       (workflow V1 — PENDING et OPTIONAL sont des phases préparatoires sans réservation).</li>
 *   <li><b>Toute mutation de booking</b> : bloquée si la date est {@code LOCKED} ou {@code CANCELLED}.</li>
 * </ul>
 *
 * <p>Mappée en HTTP 409 Conflict par {@link mapper.ShowDateNotModifiableExceptionMapper}.
 */
public class ShowDateNotModifiableException extends RuntimeException {

    public ShowDateNotModifiableException() {
        super("La date de spectacle est verrouillée ou annulée. Aucune modification de booking n'est autorisée.");
    }

    public ShowDateNotModifiableException(String message) {
        super(message);
    }
}
