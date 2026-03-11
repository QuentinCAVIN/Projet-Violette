package io.violette.showdate.dto;

import io.violette.showdate.model.AvailabilityStatus;

import java.time.Instant;

/**
 * DTO de disponibilité artiste exposé par l'API.
 * Les champs de la clé composite (showDateId, artistId) sont aplatis pour la lisibilité API.
 */
public record ArtistAvailabilityDto(
        Long showDateId,
        Long artistId,
        String artistFirstName,
        String artistLastName,
        AvailabilityStatus status,
        Instant updatedAt
) {
}
