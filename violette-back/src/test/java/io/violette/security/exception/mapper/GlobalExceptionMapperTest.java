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
    @DisplayName("Exception non mappée → 500 avec corps neutre sans détail technique")
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
    @DisplayName("WebApplicationException / BadRequestException → statut d'origine (400), pas 500")
    void webApplicationException_preservesOriginalStatus() {
        String businessMessage = "Transition de statut non autorisée";
        Response response = globalMapper.toResponse(new BadRequestException(businessMessage));

        assertEquals(Response.Status.BAD_REQUEST.getStatusCode(), response.getStatus());
        assertNotEquals(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), response.getStatus());
        assertEquals(businessMessage, response.getEntity());
    }

    @Test
    @DisplayName("Mapper métier ShowDateNotFoundException → 404 inchangé (non-régression)")
    void businessExceptionMapper_stillReturnsOriginalStatus() {
        Response response = showDateNotFoundMapper.toResponse(new ShowDateNotFoundException());

        assertEquals(Response.Status.NOT_FOUND.getStatusCode(), response.getStatus());
        assertNotEquals(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), response.getStatus());
        assertTrue(response.getEntity().toString().contains("introuvable"));
    }
}
