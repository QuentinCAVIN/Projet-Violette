package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.BookingAlreadyExistsException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme BookingAlreadyExistsException en HTTP 409 Conflict.
 */
@Provider
public class BookingAlreadyExistsExceptionMapper implements ExceptionMapper<BookingAlreadyExistsException> {

    @Override
    public Response toResponse(BookingAlreadyExistsException exception) {
        return Response.status(Response.Status.CONFLICT)
                .entity(exception.getMessage())
                .build();
    }
}
