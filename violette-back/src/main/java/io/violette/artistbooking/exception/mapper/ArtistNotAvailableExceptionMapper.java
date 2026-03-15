package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.ArtistNotAvailableException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme ArtistNotAvailableException en HTTP 409 Conflict.
 */
@Provider
public class ArtistNotAvailableExceptionMapper implements ExceptionMapper<ArtistNotAvailableException> {

    @Override
    public Response toResponse(ArtistNotAvailableException exception) {
        return Response.status(Response.Status.CONFLICT)
                .entity(exception.getMessage())
                .build();
    }
}
