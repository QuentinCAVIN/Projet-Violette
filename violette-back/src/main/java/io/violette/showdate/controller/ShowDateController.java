package io.violette.showdate.controller;

import io.quarkus.security.Authenticated;
import io.violette.security.CurrentUserContextProvider;
import io.violette.showdate.dto.ArtistAvailabilityDto;
import io.violette.showdate.dto.CreateShowDateRequestDto;
import io.violette.showdate.dto.CreateSkillRequirementRequestDto;
import io.violette.showdate.dto.ShowDateDto;
import io.violette.showdate.dto.ShowDateSkillRequirementDto;
import io.violette.showdate.dto.UpsertAvailabilityRequestDto;
import io.violette.showdate.service.ArtistAvailabilityService;
import io.violette.showdate.service.ShowDateService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
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
 * Contrôleur du domaine showdate. Délègue toute la logique au service.
 * Pas de logique métier ici — uniquement routage HTTP et délégation.
 */
@Path("/show-dates")
@Tag(name = "Dates de spectacle", description = "Gestion des dates de spectacle (feuilles de route)")
@Authenticated
public class ShowDateController {

    @Inject
    ShowDateService showDateService;

    @Inject
    ArtistAvailabilityService artistAvailabilityService;

    @Inject
    CurrentUserContextProvider currentUserContextProvider;

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Créer une date de spectacle", description = "Crée une nouvelle date de spectacle pour une compagnie. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "201", description = "Date créée", content = @Content(schema = @Schema(implementation = ShowDateDto.class)))
    @APIResponse(responseCode = "400", description = "Corps de la requête invalide")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Compagnie ou revue introuvable")
    public Response create(@Valid CreateShowDateRequestDto request) {
        ShowDateDto dto = showDateService.createShowDate(request);
        return Response.status(Response.Status.CREATED).entity(dto).build();
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Lister toutes les dates de spectacle", description = "Retourne toutes les dates de spectacle, triées par date croissante. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Liste des dates", content = @Content(schema = @Schema(implementation = ShowDateDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    public Response getAll() {
        List<ShowDateDto> dtos = showDateService.getAll();
        return Response.ok(dtos).build();
    }

    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Récupérer une date par id", description = "Retourne le détail d'une date de spectacle. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Date trouvée", content = @Content(schema = @Schema(implementation = ShowDateDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date introuvable")
    public Response getById(@PathParam("id") Long id) {
        ShowDateDto dto = showDateService.getById(id);
        return Response.ok(dto).build();
    }

    @DELETE
    @Path("/{id}")
    @RolesAllowed("MANAGER")
    @Operation(summary = "Supprimer une date de spectacle", description = "Supprime une date de spectacle par son identifiant. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "204", description = "Date supprimée")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date introuvable")
    public Response deleteById(@PathParam("id") Long id) {
        showDateService.deleteShowDate(id);
        return Response.noContent().build();
    }

    @GET
    @Path("/company/{companyId}")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Lister les dates d'une compagnie", description = "Retourne toutes les dates de spectacle d'une compagnie. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Liste des dates", content = @Content(schema = @Schema(implementation = ShowDateDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Compagnie introuvable")
    public Response getByCompanyId(@PathParam("companyId") Long companyId) {
        List<ShowDateDto> dtos = showDateService.getByCompanyId(companyId);
        return Response.ok(dtos).build();
    }

    @POST
    @Path("/{id}/skill-requirements")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Ajouter un besoin artistique", description = "Ajoute un besoin artistique par compétence à une date de spectacle. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "201", description = "Besoin ajouté", content = @Content(schema = @Schema(implementation = ShowDateSkillRequirementDto.class)))
    @APIResponse(responseCode = "400", description = "Corps de la requête invalide")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date introuvable")
    public Response addSkillRequirement(@PathParam("id") Long id, @Valid CreateSkillRequirementRequestDto request) {
        ShowDateSkillRequirementDto dto = showDateService.addSkillRequirement(id, request);
        return Response.status(Response.Status.CREATED).entity(dto).build();
    }

    @GET
    @Path("/{id}/skill-requirements")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(summary = "Lister les besoins artistiques d'une date", description = "Retourne les besoins artistiques par compétence pour une date de spectacle. Requiert le rôle MANAGER.")
    @APIResponse(responseCode = "200", description = "Liste des besoins", content = @Content(schema = @Schema(implementation = ShowDateSkillRequirementDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date introuvable")
    public Response getSkillRequirements(@PathParam("id") Long id) {
        List<ShowDateSkillRequirementDto> dtos = showDateService.getSkillRequirements(id);
        return Response.ok(dtos).build();
    }

    @GET
    @Path("/{id}/availabilities")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(
            summary = "Lister les disponibilités artistes d'une date",
            description = "Retourne toutes les disponibilités déclarées pour une date de spectacle. Requiert le rôle MANAGER."
    )
    @APIResponse(responseCode = "200", description = "Liste des disponibilités", content = @Content(schema = @Schema(implementation = ArtistAvailabilityDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date introuvable")
    public Response getAvailabilitiesForShowDate(@PathParam("id") Long id) {
        List<ArtistAvailabilityDto> dtos = artistAvailabilityService.getAvailabilitiesForShowDate(id);
        return Response.ok(dtos).build();
    }

    @PUT
    @Path("/{id}/availabilities/me")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("ARTIST")
    @Operation(
            summary = "Déclarer ou mettre à jour ma disponibilité",
            description = "Crée ou met à jour la disponibilité de l'artiste authentifié pour cette date. Le statut PENDING ne peut pas être envoyé explicitement. Requiert le rôle ARTIST."
    )
    @APIResponse(responseCode = "200", description = "Disponibilité enregistrée", content = @Content(schema = @Schema(implementation = ArtistAvailabilityDto.class)))
    @APIResponse(responseCode = "400", description = "Corps de la requête invalide ou statut PENDING explicite interdit")
    @APIResponse(responseCode = "401", description = "Principal JWT introuvable")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date ou utilisateur introuvable")
    public Response upsertMyAvailability(@PathParam("id") Long id, @Valid UpsertAvailabilityRequestDto request) {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(principal -> {
                    ArtistAvailabilityDto dto = artistAvailabilityService.upsertMyAvailability(id, principal, request.status());
                    return Response.ok(dto).build();
                })
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }
}
