package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.ArtistBookingNotFoundException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme ArtistBookingNotFoundException en HTTP 404 Not Found.
 */
@Provider
public class ArtistBookingNotFoundExceptionMapper implements ExceptionMapper<ArtistBookingNotFoundException> {

    @Override
    public Response toResponse(ArtistBookingNotFoundException exception) {
        return Response.status(Response.Status.NOT_FOUND)
                .entity(exception.getMessage())
                .build();
    }
}
