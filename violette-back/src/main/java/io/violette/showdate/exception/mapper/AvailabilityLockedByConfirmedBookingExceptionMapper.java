package io.violette.showdate.exception.mapper;

import io.violette.showdate.exception.AvailabilityLockedByConfirmedBookingException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme AvailabilityLockedByConfirmedBookingException en HTTP 409 Conflict.
 */
@Provider
public class AvailabilityLockedByConfirmedBookingExceptionMapper
        implements ExceptionMapper<AvailabilityLockedByConfirmedBookingException> {

    @Override
    public Response toResponse(AvailabilityLockedByConfirmedBookingException exception) {
        return Response.status(Response.Status.CONFLICT)
                .entity(exception.getMessage())
                .build();
    }
}
