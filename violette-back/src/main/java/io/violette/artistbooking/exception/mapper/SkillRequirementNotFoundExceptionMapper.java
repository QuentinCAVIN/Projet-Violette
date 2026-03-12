package io.violette.artistbooking.exception.mapper;

import io.violette.artistbooking.exception.SkillRequirementNotFoundException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

/**
 * Transforme SkillRequirementNotFoundException en HTTP 404 Not Found.
 */
@Provider
public class SkillRequirementNotFoundExceptionMapper implements ExceptionMapper<SkillRequirementNotFoundException> {

    @Override
    public Response toResponse(SkillRequirementNotFoundException exception) {
        return Response.status(Response.Status.NOT_FOUND)
                .entity(exception.getMessage())
                .build();
    }
}
