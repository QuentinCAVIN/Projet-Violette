package io.violette.violetteuser.exception;

/**
 * Exception métier : un utilisateur avec le même firebaseUid ou email existe déjà.
 * Mappée en HTTP 409 Conflict par {@link io.violette.violetteuser.exception.mapper.UserExceptionMapper}.
 */
public class UserAlreadyExistsException extends RuntimeException {

    public UserAlreadyExistsException() {
        super("Un utilisateur avec ce firebaseUid ou cet email existe déjà.");
    }

    public UserAlreadyExistsException(String message) {
        super(message);
    }
}
