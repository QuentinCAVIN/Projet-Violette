package io.violette.cabaretcompany.controller;

import io.quarkus.security.Authenticated;
import io.violette.cabaretcompany.dto.CabaretCompanyDto;
import io.violette.cabaretcompany.dto.CabaretShowDto;
import io.violette.cabaretcompany.dto.CompanyMemberDto;
import io.violette.cabaretcompany.service.CabaretCompanyService;
import io.violette.cabaretcompany.service.CabaretShowService;
import io.violette.security.CurrentUserContextProvider;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

import java.util.List;

/**
 * Contrôleur du domaine cabaretcompany. Délègue toute la logique au service.
 * Squelette — les endpoints de création/modification seront ajoutés ultérieurement.
 */
@Path("/companies")
@Tag(name = "Compagnies", description = "Gestion des compagnies de cabaret et de leurs revues")
@Authenticated
public class CabaretCompanyController {

    @Inject
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    CabaretCompanyService cabaretCompanyService;

    @Inject
    CabaretShowService cabaretShowService;

    @GET
    @Path("/mine")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(
            summary = "Ma compagnie",
            description = "Retourne la compagnie dont l'utilisateur authentifié est le manager (un manager = une compagnie en Violette ; profil backend résolu depuis le JWT). Requiert le rôle MANAGER."
    )
    @APIResponse(responseCode = "200", description = "Compagnie trouvée", content = @Content(schema = @Schema(implementation = CabaretCompanyDto.class)))
    @APIResponse(responseCode = "401", description = "Principal JWT introuvable ou invalide")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Aucun profil backend pour cet utilisateur, ou aucune compagnie pour ce manager")
    public Response getMine() {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(principal -> Response.ok(cabaretCompanyService.getMine(principal)).build())
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }

    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Récupérer une compagnie par id", description = "Retourne le détail d'une compagnie. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Compagnie trouvée", content = @Content(schema = @Schema(implementation = CabaretCompanyDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Compagnie introuvable")
    public Response getById(@PathParam("id") Long id) {
        CabaretCompanyDto dto = cabaretCompanyService.getById(id);
        return Response.ok(dto).build();
    }

    @GET
    @Path("/{id}/members")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Lister les membres d'une compagnie", description = "Retourne les artistes membres d'une compagnie. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Liste des membres", content = @Content(schema = @Schema(implementation = CompanyMemberDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Compagnie introuvable")
    public Response getMembers(@PathParam("id") Long id) {
        List<CompanyMemberDto> members = cabaretCompanyService.getMembersByCompanyId(id);
        return Response.ok(members).build();
    }

    @GET
    @Path("/{id}/shows")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Lister les revues d'une compagnie", description = "Retourne les revues d'une compagnie. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Liste des revues", content = @Content(schema = @Schema(implementation = CabaretShowDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Compagnie introuvable")
    public Response getShows(@PathParam("id") Long id) {
        List<CabaretShowDto> shows = cabaretShowService.getByCompanyId(id);
        return Response.ok(shows).build();
    }
}
