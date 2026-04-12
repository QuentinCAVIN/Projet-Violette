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
@Tag(name = "Utilisateurs", description = "Gestion des profils utilisateurs et du contexte authentifié")
@Authenticated
public class VioletteUserController {

    @Inject
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    VioletteUserService violetteUserService;

    @GET
    @Path("/me")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Contexte de l'utilisateur courant", description = "Retourne les informations de l'utilisateur authentifié depuis le JWT (firebaseUid, email, nom).")
    @APIResponse(responseCode = "200", description = "Utilisateur authentifié", content = @Content(schema = @Schema(implementation = AuthenticatedUserDto.class)))
    @APIResponse(responseCode = "401", description = "Non authentifié (token absent ou invalide)")
    public Response me() {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(violetteUserService::getCurrentUser)
                .map(dto -> Response.ok(dto).build())
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }

    @GET
    @Path("/me/profile")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Profil complet de l'utilisateur courant", description = "Retourne le profil backend complet (firstName, lastName, rôles, compétences) de l'utilisateur authentifié. Accessible à tout utilisateur ayant un profil backend créé.")
    @APIResponse(responseCode = "200", description = "Profil complet retourné", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "401", description = "Non authentifié (token absent ou invalide)")
    @APIResponse(responseCode = "404", description = "Aucun profil backend pour cet utilisateur (profil non encore créé)")
    public Response getMyProfile() {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(violetteUserService::getMyProfile)
                .map(dto -> Response.ok(dto).build())
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Créer un profil utilisateur", description = "Crée un profil utilisateur backend à partir du JWT (firebaseUid, email) et du corps de requête (firstName, lastName, roles).")
    @APIResponse(responseCode = "201", description = "Utilisateur créé", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "401", description = "Non authentifié")
    @APIResponse(responseCode = "409", description = "Utilisateur déjà existant (même firebaseUid ou email)")
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
    @Operation(summary = "Récupérer un utilisateur par Firebase UID", description = "Retourne le profil utilisateur par Firebase UID. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Utilisateur trouvé", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Utilisateur introuvable")
    public Response getByFirebaseUid(@jakarta.ws.rs.PathParam("firebaseUid") String firebaseUid) {
        VioletteUserDto dto = violetteUserService.getUserByFirebaseUid(firebaseUid);
        return Response.ok(dto).build();
    }

    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Récupérer un utilisateur par identifiant", description = "Retourne le profil utilisateur par identifiant. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Utilisateur trouvé", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Utilisateur introuvable")
    public Response getById(@jakarta.ws.rs.PathParam("id") Long id) {
        VioletteUserDto dto = violetteUserService.getUserById(id);
        return Response.ok(dto).build();
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Lister les utilisateurs (pagination)", description = "Retourne la liste paginée des utilisateurs, triée par createdAt DESC. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Liste des utilisateurs", content = @Content(schema = @Schema(implementation = VioletteUserDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    public Response listUsers(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("size") @DefaultValue("20") int size) {
        List<VioletteUserDto> list = violetteUserService.getUsers(page, size);
        return Response.ok(list).build();
    }
}
