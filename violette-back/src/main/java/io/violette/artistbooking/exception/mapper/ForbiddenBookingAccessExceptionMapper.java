package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.ForbiddenBookingAccessException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme {@link ForbiddenBookingAccessException} en HTTP 403 Forbidden.
 * Le corps est volontairement court et neutre pour ne pas divulguer l'existence
 * de ressources tierces.
 */
@Provider
public class ForbiddenBookingAccessExceptionMapper implements ExceptionMapper<ForbiddenBookingAccessException> {

    @Override
    public Response toResponse(ForbiddenBookingAccessException exception) {
        return Response.status(Response.Status.FORBIDDEN)
                .entity("Accès refusé.")
                .build();
    }
}
