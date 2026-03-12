package io.violette.artistbooking.exception;

/**
 * Exception métier : l'artiste n'a pas déclaré sa disponibilité comme {@code AVAILABLE}
 * pour cette date. Seul le statut {@code AVAILABLE} autorise la sélection.
 * Mappée en HTTP 409 Conflict par {@link mapper.ArtistNotAvailableExceptionMapper}.
 */
public class ArtistNotAvailableException extends RuntimeException {

    public ArtistNotAvailableException() {
        super("L'artiste n'est pas disponible (statut requis : AVAILABLE).");
    }

    public ArtistNotAvailableException(String message) {
        super(message);
    }
}
