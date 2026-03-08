package io.violette.violetteuser.controller;

import io.quarkus.security.Authenticated;
import io.violette.security.CurrentUserContextProvider;
import io.violette.violetteuser.dto.AuthenticatedUserDto;
import io.violette.violetteuser.service.VioletteUserService;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

/**
 * Contrôleur utilisateur. Délègue toute la logique au service ; pas de gestion sécurité ni JWT ici.
 */
@Path("/users")
@Tag(name = "Users", description = "Authenticated user profile and context")
@Authenticated
public class VioletteUserController {

    @Inject
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    VioletteUserService violetteUserService;

    @GET
    @Path("/me")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Current user context", description = "Returns authenticated user info from JWT (firebaseUid, email, name).")
    @APIResponse(responseCode = "200", description = "Authenticated user", content = @Content(schema = @Schema(implementation = AuthenticatedUserDto.class)))
    @APIResponse(responseCode = "401", description = "Not authenticated (missing or invalid token)")
    public Response me() {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(violetteUserService::getCurrentUser)
                .map(dto -> Response.ok(dto).build())
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }
}
