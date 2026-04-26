package io.violette.artistbooking.controller;

import io.quarkus.security.Authenticated;
import io.violette.artistbooking.dto.ArtistBookingDto;
import io.violette.artistbooking.dto.CreateBookingRequestDto;
import io.violette.artistbooking.dto.RespondToBookingRequestDto;
import io.violette.artistbooking.service.ArtistBookingService;
import io.violette.security.CurrentUserContextProvider;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PATCH;
import jakarta.ws.rs.POST;
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
 * Contrôleur du domaine artistbooking.
 * Délègue toute la logique au service — aucune règle métier ici.
 *
 * <p>Préfixe global : {@code /api} (via {@code quarkus.rest.path=/api}).
 * Base path de ce contrôleur : {@code /artist-bookings}.
 */
@Path("/artist-bookings")
@Tag(name = "Réservations artistes", description = "Gestion des réservations artistes pour les dates de spectacle")
@Authenticated
public class ArtistBookingController {

    @Inject
    ArtistBookingService artistBookingService;

    @Inject
    CurrentUserContextProvider currentUserContextProvider;

    // ------------------------------------------------------------------
    // Manager — sélection
    // ------------------------------------------------------------------

    /**
     * Sélectionne un artiste pour une date (MANAGER).
     * Crée un booking en statut {@code SELECTED}.
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(
            summary = "Sélectionner un artiste pour une date",
            description = "Crée une réservation en statut SELECTED pour un artiste sur une date. Requiert le rôle MANAGER."
    )
    @APIResponse(responseCode = "201", description = "Artiste sélectionné", content = @Content(schema = @Schema(implementation = ArtistBookingDto.class)))
    @APIResponse(responseCode = "400", description = "Corps de la requête invalide")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date ou artiste introuvable")
    @APIResponse(responseCode = "409", description = "Réservation déjà existante, artiste non disponible ou capacité atteinte")
    public Response createBooking(@Valid CreateBookingRequestDto request) {
        ArtistBookingDto dto = artistBookingService.createBooking(request);
        return Response.status(Response.Status.CREATED).entity(dto).build();
    }

    // ------------------------------------------------------------------
    // Manager — désélection
    // ------------------------------------------------------------------

    /**
     * Désélectionne un artiste (MANAGER).
     * Supprime le booking. Uniquement possible si le statut est {@code SELECTED}.
     */
    @DELETE
    @Path("/{id}")
    @RolesAllowed("MANAGER")
    @Operation(
            summary = "Désélectionner un artiste",
            description = "Supprime une réservation en statut SELECTED. Requiert le rôle MANAGER."
    )
    @APIResponse(responseCode = "204", description = "Artiste désélectionné")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Réservation introuvable")
    @APIResponse(responseCode = "409", description = "La réservation n'est plus en statut SELECTED")
    public Response deleteBooking(@PathParam("id") Long id) {
        artistBookingService.deleteBooking(id);
        return Response.noContent().build();
    }

    // ------------------------------------------------------------------
    // Manager — envoi des demandes de confirmation
    // ------------------------------------------------------------------

    /**
     * Envoie les demandes de confirmation à tous les artistes sélectionnés d'une date (MANAGER).
     * Passe tous les bookings {@code SELECTED} en {@code PENDING_CONFIRMATION}.
     */
    @POST
    @Path("/show-dates/{showDateId}/send-confirmations")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(
            summary = "Envoyer les demandes de confirmation",
            description = "Passe toutes les réservations SELECTED de la date en PENDING_CONFIRMATION. Requiert le rôle MANAGER."
    )
    @APIResponse(responseCode = "200", description = "Demandes envoyées", content = @Content(schema = @Schema(implementation = ArtistBookingDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date introuvable")
    @APIResponse(responseCode = "409", description = "La date est verrouillée ou annulée")
    public Response sendConfirmationRequests(@PathParam("showDateId") Long showDateId) {
        List<ArtistBookingDto> dtos = artistBookingService.sendConfirmationRequests(showDateId);
        return Response.ok(dtos).build();
    }

    // ------------------------------------------------------------------
    // Manager — lecture des bookings d'une date
    // ------------------------------------------------------------------

    /**
     * Retourne tous les bookings d'une date de spectacle (MANAGER).
     */
    @GET
    @Path("/show-dates/{showDateId}")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("MANAGER")
    @Operation(
            summary = "Lister les réservations d'une date",
            description = "Retourne toutes les réservations d'une date de spectacle. Requiert le rôle MANAGER."
    )
    @APIResponse(responseCode = "200", description = "Liste des réservations", content = @Content(schema = @Schema(implementation = ArtistBookingDto.class)))
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Date introuvable")
    public Response getBookingsForShowDate(@PathParam("showDateId") Long showDateId) {
        List<ArtistBookingDto> dtos = artistBookingService.getBookingsForShowDate(showDateId);
        return Response.ok(dtos).build();
    }

    // ------------------------------------------------------------------
    // Artiste — réponse à une demande de confirmation
    // ------------------------------------------------------------------

    /**
     * L'artiste accepte ou refuse une demande de confirmation (ARTIST).
     * Transitions autorisées depuis {@code PENDING_CONFIRMATION} uniquement.
     */
    @PATCH
    @Path("/{id}/respond")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("ARTIST")
    @Operation(
            summary = "Répondre à une demande de confirmation",
            description = "L'artiste accepte (CONFIRMED) ou refuse (REFUSED) une demande. Requiert le rôle ARTIST."
    )
    @APIResponse(responseCode = "200", description = "Réponse enregistrée", content = @Content(schema = @Schema(implementation = ArtistBookingDto.class)))
    @APIResponse(responseCode = "400", description = "Corps de la requête invalide")
    @APIResponse(responseCode = "401", description = "Non authentifié")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    @APIResponse(responseCode = "404", description = "Réservation introuvable")
    @APIResponse(responseCode = "409", description = "La réservation n'est pas en statut PENDING_CONFIRMATION")
    public Response respondToRequest(
            @PathParam("id") Long id,
            @Valid RespondToBookingRequestDto request) {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(principal -> {
                    ArtistBookingDto dto = artistBookingService.respondToRequest(id, request.accept(), principal);
                    return Response.ok(dto).build();
                })
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }

    // ------------------------------------------------------------------
    // Artiste — demandes en attente
    // ------------------------------------------------------------------

    /**
     * Retourne les demandes de confirmation en attente pour l'artiste authentifié (ARTIST).
     * Filtre sur le statut {@code PENDING_CONFIRMATION}.
     */
    @GET
    @Path("/me/pending")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("ARTIST")
    @Operation(
            summary = "Mes demandes de confirmation en attente",
            description = "Retourne les réservations PENDING_CONFIRMATION de l'artiste authentifié. Requiert le rôle ARTIST."
    )
    @APIResponse(responseCode = "200", description = "Liste des demandes en attente", content = @Content(schema = @Schema(implementation = ArtistBookingDto.class)))
    @APIResponse(responseCode = "401", description = "Non authentifié")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    public Response getPendingBookings() {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(principal -> {
                    List<ArtistBookingDto> dtos = artistBookingService.getPendingBookingsForCurrentArtist(principal);
                    return Response.ok(dtos).build();
                })
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }

    /**
     * Retourne tous les bookings de l'artiste authentifié (ARTIST).
     * Permet au frontend de connaître les engagements confirmés sans exposer les bookings d'autres artistes.
     */
    @GET
    @Path("/me")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed("ARTIST")
    @Operation(
            summary = "Mes réservations",
            description = "Retourne toutes les réservations de l'artiste authentifié. Requiert le rôle ARTIST."
    )
    @APIResponse(responseCode = "200", description = "Liste des réservations de l'artiste", content = @Content(schema = @Schema(implementation = ArtistBookingDto.class)))
    @APIResponse(responseCode = "401", description = "Non authentifié")
    @APIResponse(responseCode = "403", description = "Accès refusé (rôle insuffisant)")
    public Response getMyBookings() {
        return currentUserContextProvider.getCurrentPrincipal()
                .map(principal -> {
                    List<ArtistBookingDto> dtos = artistBookingService.getBookingsForCurrentArtist(principal);
                    return Response.ok(dtos).build();
                })
                .orElse(Response.status(Response.Status.UNAUTHORIZED).build());
    }
}
