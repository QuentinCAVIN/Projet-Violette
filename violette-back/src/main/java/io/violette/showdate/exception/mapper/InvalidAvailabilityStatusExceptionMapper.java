package io.violette.showdate.exception.mapper;

import io.violette.showdate.exception.InvalidAvailabilityStatusException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme InvalidAvailabilityStatusException en HTTP 400 Bad Request.
 */
@Provider
public class InvalidAvailabilityStatusExceptionMapper implements ExceptionMapper<InvalidAvailabilityStatusException> {

    @Override
    public Response toResponse(InvalidAvailabilityStatusException exception) {
        return Response.status(Response.Status.BAD_REQUEST)
                .entity(exception.getMessage())
                .build();
    }
}
