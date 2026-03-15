package io.violette.violetteuser.controller;

import io.quarkus.security.Authenticated;
import io.violette.security.CurrentUserContextProvider;
import io.violette.violetteuser.dto.AuthenticatedUserDto;
import io.violette.violetteuser.dto.CreateUserRequestDto;
import io.violette.violetteuser.dto.VioletteUserDto;
import io.violette.violetteuser.service.VioletteUserService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

import java.util.List;

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

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Create user profile", description = "Creates backend user profile from JWT (firebaseUid, email) and request body (firstName, lastName, roles).")
    @APIResponse(responseCode = "201", description = "User created", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "401", description = "Not authenticated")
    @APIResponse(responseCode = "409", description = "User already exists (same firebaseUid or email)")
    public Response createUser(@Valid CreateUserRequestDto request) {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(principal -> {
                    VioletteUserDto dto = violetteUserService.createUser(principal, request);
                    return Response.status(Response.Status.CREATED).entity(dto).build();
                })
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }

    @GET
    @Path("/by-firebase/{firebaseUid}")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Get user by Firebase UID", description = "Returns user profile by Firebase UID. Requires MANAGER role.")
    @APIResponse(responseCode = "200", description = "User found", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "403", description = "Forbidden (insufficient role)")
    @APIResponse(responseCode = "404", description = "User not found")
    public Response getByFirebaseUid(@jakarta.ws.rs.PathParam("firebaseUid") String firebaseUid) {
        VioletteUserDto dto = violetteUserService.getUserByFirebaseUid(firebaseUid);
        return Response.ok(dto).build();
    }

    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Get user by ID", description = "Returns user profile by id. Requires MANAGER role.")
    @APIResponse(responseCode = "200", description = "User found", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "403", description = "Forbidden (insufficient role)")
    @APIResponse(responseCode = "404", description = "User not found")
    public Response getById(@jakarta.ws.rs.PathParam("id") Long id) {
        VioletteUserDto dto = violetteUserService.getUserById(id);
        return Response.ok(dto).build();
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "List users (paginated)", description = "Returns paginated list of users, sorted by createdAt DESC. Requires MANAGER role.")
    @APIResponse(responseCode = "200", description = "List of users", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "403", description = "Forbidden (insufficient role)")
    public Response listUsers(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("size") @DefaultValue("20") int size) {
        List<VioletteUserDto> list = violetteUserService.getUsers(page, size);
        return Response.ok(list).build();
    }
}
