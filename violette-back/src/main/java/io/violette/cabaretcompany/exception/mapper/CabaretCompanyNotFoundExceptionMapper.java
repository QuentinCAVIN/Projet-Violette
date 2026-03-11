package io.violette.cabaretcompany.exception.mapper;

import io.violette.cabaretcompany.exception.CabaretCompanyNotFoundException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme CabaretCompanyNotFoundException en HTTP 404 Not Found.
 */
@Provider
public class CabaretCompanyNotFoundExceptionMapper implements ExceptionMapper<CabaretCompanyNotFoundException> {

    @Override
    public Response toResponse(CabaretCompanyNotFoundException exception) {
        return Response.status(Response.Status.NOT_FOUND)
                .entity(exception.getMessage())
                .build();
    }
}
