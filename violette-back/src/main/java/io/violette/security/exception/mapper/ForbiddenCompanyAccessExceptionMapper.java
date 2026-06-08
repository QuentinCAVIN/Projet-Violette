package io.violette.security.exception.mapper;

import io.violette.security.exception.ForbiddenCompanyAccessException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme {@link ForbiddenCompanyAccessException} en HTTP 403 Forbidden.
 * Le corps est volontairement court et neutre pour ne pas divulguer l'existence
 * de ressources tierces.
 */
@Provider
public class ForbiddenCompanyAccessExceptionMapper implements ExceptionMapper<ForbiddenCompanyAccessException> {

    @Override
    public Response toResponse(ForbiddenCompanyAccessException exception) {
        return Response.status(Response.Status.FORBIDDEN)
                .entity("Accès refusé.")
                .build();
    }
}
