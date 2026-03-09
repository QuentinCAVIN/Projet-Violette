package io.violette.violetteuser.exception.mapper;

import io.violette.violetteuser.exception.UserAlreadyExistsException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme les exceptions métier du domaine utilisateur en réponses HTTP.
 * UserAlreadyExistsException → 409 Conflict.
 */
@Provider
public class UserExceptionMapper implements ExceptionMapper<UserAlreadyExistsException> {

    @Override
    public Response toResponse(UserAlreadyExistsException exception) {
        return Response.status(Response.Status.CONFLICT)
                .entity(exception.getMessage())
                .build();
    }
}
