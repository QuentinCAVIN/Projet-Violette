package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.BookingCapacityExceededException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme BookingCapacityExceededException en HTTP 409 Conflict.
 */
@Provider
public class BookingCapacityExceededExceptionMapper implements ExceptionMapper<BookingCapacityExceededException> {

    @Override
    public Response toResponse(BookingCapacityExceededException exception) {
        return Response.status(Response.Status.CONFLICT)
                .entity(exception.getMessage())
                .build();
    }
}
