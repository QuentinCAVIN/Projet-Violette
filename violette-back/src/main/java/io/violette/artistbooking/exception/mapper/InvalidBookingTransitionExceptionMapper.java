package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.InvalidBookingTransitionException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme InvalidBookingTransitionException en HTTP 409 Conflict.
 */
@Provider
public class InvalidBookingTransitionExceptionMapper implements ExceptionMapper<InvalidBookingTransitionException> {

    @Override
    public Response toResponse(InvalidBookingTransitionException exception) {
        return Response.status(Response.Status.CONFLICT)
                .entity(exception.getMessage())
                .build();
    }
}
