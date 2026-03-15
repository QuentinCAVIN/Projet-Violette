package io.violette.artistbooking.dto;

import io.violette.artistbooking.model.BookingStatus;
import io.violette.violetteuser.model.ArtistSkill;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

/**
 * DTO en lecture d'un booking artiste.
 * Aplatit les relations (showDate, artist, skillRequirement) pour l'API.
 *
 * @param id                  identifiant du booking
 * @param showDateId          identifiant de la date de spectacle
 * @param eventDate           date du spectacle (dénormalisée pour faciliter l'affichage)
 * @param artistId            identifiant de l'artiste
 * @param artistFirstName     prénom de l'artiste
 * @param artistLastName      nom de l'artiste
 * @param skillRequirementId  identifiant du besoin artistique couvert (nullable)
 * @param skill               compétence du besoin artistique (nullable)
 * @param status              statut courant du booking
 * @param agreedNetFee        cachet net figé au moment de la sélection (nullable)
 * @param createdAt           date de création (sélection initiale)
 * @param updatedAt           date de dernière modification
 * @param requestedAt         date d'envoi de la demande de confirmation (nullable)
 * @param respondedAt         date de réponse de l'artiste (nullable)
 */
public record ArtistBookingDto(
        Long id,
        Long showDateId,
        LocalDate eventDate,
        Long artistId,
        String artistFirstName,
        String artistLastName,
        Long skillRequirementId,
        ArtistSkill skill,
        BookingStatus status,
        BigDecimal agreedNetFee,
        Instant createdAt,
        Instant updatedAt,
        Instant requestedAt,
        Instant respondedAt
) {}
