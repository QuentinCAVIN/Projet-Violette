package io.violette.artistbooking.dto;

import jakarta.validation.constraints.NotNull;

/**
 * Corps de la requête de sélection d'un artiste pour une date.
 *
 * @param showDateId         identifiant de la date de spectacle (obligatoire)
 * @param artistId           identifiant de l'artiste à sélectionner (obligatoire)
 * @param skillRequirementId identifiant du besoin artistique couvert (nullable — recommandé)
 */
public record CreateBookingRequestDto(
        @NotNull Long showDateId,
        @NotNull Long artistId,
        Long skillRequirementId
) {}
