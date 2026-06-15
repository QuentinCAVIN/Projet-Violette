package io.violette.security.exception.mapper;

import io.violette.security.exception.dto.InternalErrorResponse;
import jakarta.annotation.Priority;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

/**
 * Filet de sécurité pour les exceptions non couvertes par les mappers métier.
 * <p>
 * En JAX-RS, le mapper le plus spécifique l'emporte : les 15 mappers métier
 * (ex. {@link io.violette.showdate.exception.mapper.ShowDateNotFoundExceptionMapper})
 * restent prioritaires sur ce mapper {@code Throwable}.
 * <p>
 * Les {@link WebApplicationException} (ex. {@code BadRequestException}) conservent
 * leur statut HTTP d'origine et ne sont pas transformées en 500.
 */
@Provider
@Priority(Priorities.USER - 100)
public class GlobalExceptionMapper implements ExceptionMapper<Throwable> {

    private static final Logger LOG = LoggerFactory.getLogger(GlobalExceptionMapper.class);
    private static final String GENERIC_ERROR_MESSAGE = "Une erreur interne est survenue";

    @Override
    public Response toResponse(Throwable exception) {
        if (exception instanceof WebApplicationException webApplicationException) {
            return webApplicationException.getResponse();
        }

        String reference = UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        LOG.error("Erreur interne non gérée [reference={}]", reference, exception);

        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .type(MediaType.APPLICATION_JSON)
                .entity(new InternalErrorResponse(GENERIC_ERROR_MESSAGE, reference))
                .build();
    }
}
