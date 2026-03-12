package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.ShowDateNotModifiableException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme ShowDateNotModifiableException en HTTP 409 Conflict.
 */
@Provider
public class ShowDateNotModifiableExceptionMapper implements ExceptionMapper<ShowDateNotModifiableException> {

    @Override
    public Response toResponse(ShowDateNotModifiableException exception) {
        return Response.status(Response.Status.CONFLICT)
                .entity(exception.getMessage())
                .build();
    }
}
