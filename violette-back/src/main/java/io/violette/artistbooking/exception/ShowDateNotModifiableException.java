package io.violette.artistbooking.exception;

/**
 * Exception métier : la date de spectacle n'est pas dans un état compatible avec l'opération demandée.
 *
 * <p>Levée dans trois contextes :
 * <ul>
 *   <li><b>Présélection/sélection ({@code createBooking})</b> : la date doit être {@code OPTION}
 *       ou {@code CONFIRMED} — {@code INQUIRY} bloque toute sélection.</li>
 *   <li><b>Envoi de demandes fermes ({@code sendConfirmationRequests})</b> : la date doit être
 *       {@code CONFIRMED} — les présélections en phase {@code OPTION} ne peuvent pas encore
 *       être transformées en demandes fermes.</li>
 *   <li><b>Toute mutation de booking</b> : bloquée si la date est {@code STAFFED},
 *       {@code CANCELLED} ou {@code ARCHIVED}.</li>
 * </ul>
 *
 * <p>Mappée en HTTP 409 Conflict par {@link mapper.ShowDateNotModifiableExceptionMapper}.
 */
public class ShowDateNotModifiableException extends RuntimeException {

    public ShowDateNotModifiableException() {
        super("La date de spectacle est verrouillée, annulée ou archivée. Aucune modification de booking n'est autorisée.");
    }

    public ShowDateNotModifiableException(String message) {
        super(message);
    }
}
