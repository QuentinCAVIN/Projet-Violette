package io.violette.cabaretcompany.exception.mapper;

import io.violette.cabaretcompany.exception.CabaretShowNotFoundException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme CabaretShowNotFoundException en HTTP 404 Not Found.
 */
@Provider
public class CabaretShowNotFoundExceptionMapper implements ExceptionMapper<CabaretShowNotFoundException> {

    @Override
    public Response toResponse(CabaretShowNotFoundException exception) {
        return Response.status(Response.Status.NOT_FOUND)
                .entity(exception.getMessage())
                .build();
    }
}
