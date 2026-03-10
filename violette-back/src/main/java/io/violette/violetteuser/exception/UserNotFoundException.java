package io.violette.violetteuser.exception;

/**
 * Exception métier : utilisateur introuvable (id ou firebaseUid).
 * Mappée en HTTP 404 Not Found par {@link io.violette.violetteuser.exception.mapper.UserExceptionMapper}.
 */
public class UserNotFoundException extends RuntimeException {

    public UserNotFoundException() {
        super("Utilisateur introuvable.");
    }

    public UserNotFoundException(String message) {
        super(message);
    }
}
