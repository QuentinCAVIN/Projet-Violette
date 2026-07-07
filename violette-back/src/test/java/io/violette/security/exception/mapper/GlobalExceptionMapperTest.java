package io.violette.security.exception.mapper;

import io.violette.security.exception.dto.InternalErrorResponse;
import io.violette.showdate.exception.ShowDateNotFoundException;
import io.violette.showdate.exception.mapper.ShowDateNotFoundExceptionMapper;
import jakarta.ws.rs.BadRequestException;
import jakarta.ws.rs.core.Response;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Tests du {@link GlobalExceptionMapper} et non-régression sur les mappers métier spécifiques.
 */
class GlobalExceptionMapperTest {

    private final GlobalExceptionMapper globalMapper = new GlobalExceptionMapper();
    private final ShowDateNotFoundExceptionMapper showDateNotFoundMapper = new ShowDateNotFoundExceptionMapper();

    @Test
    @DisplayName("GlobalExceptionMapper — retourne 500 avec corps neutre quand l'exception n'est pas mappée")
    void unmappedException_returnsNeutralInternalServerError() {
        Response response = globalMapper.toResponse(
                new NullPointerException("détail-interne-ne-doit-pas-fuirer")
        );

        assertEquals(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), response.getStatus());
        assertEquals("application/json", response.getMediaType().toString());

        InternalErrorResponse body = (InternalErrorResponse) response.getEntity();
        assertEquals("Une erreur interne est survenue", body.error());
        assertNotNull(body.reference());
        assertEquals(8, body.reference().length());
        assertFalse(body.error().contains("détail-interne"));
        assertFalse(body.reference().contains("détail-interne"));
    }

    @Test
    @DisplayName("GlobalExceptionMapper — conserve le statut d'origine 400 quand une WebApplicationException est levée")
    void webApplicationException_preservesOriginalStatus() {
        // BadRequestException(String) : le message est dans getMessage(), pas dans getResponse().getEntity().
        Response response = globalMapper.toResponse(
                new BadRequestException("Transition de statut non autorisée")
        );

        assertEquals(Response.Status.BAD_REQUEST.getStatusCode(), response.getStatus());
        assertNotEquals(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), response.getStatus());
    }

    @Test
    @DisplayName("ShowDateNotFoundExceptionMapper — retourne 404 inchangé (non-régression)")
    void businessExceptionMapper_stillReturnsOriginalStatus() {
        Response response = showDateNotFoundMapper.toResponse(new ShowDateNotFoundException());

        assertEquals(Response.Status.NOT_FOUND.getStatusCode(), response.getStatus());
        assertNotEquals(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), response.getStatus());
        assertTrue(response.getEntity().toString().contains("introuvable"));
    }
}
