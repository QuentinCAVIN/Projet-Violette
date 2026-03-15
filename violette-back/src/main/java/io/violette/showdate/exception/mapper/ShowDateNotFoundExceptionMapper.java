package io.violette.showdate.exception.mapper;

import io.violette.showdate.exception.ShowDateNotFoundException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme ShowDateNotFoundException en HTTP 404 Not Found.
 */
@Provider
public class ShowDateNotFoundExceptionMapper implements ExceptionMapper<ShowDateNotFoundException> {

    @Override
    public Response toResponse(ShowDateNotFoundException exception) {
        return Response.status(Response.Status.NOT_FOUND)
                .entity(exception.getMessage())
                .build();
    }
}
