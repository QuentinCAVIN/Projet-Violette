package io.violette.showdate.dto;

import io.violette.showdate.model.ShowDateStatus;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * DTO d'une date de spectacle exposé par l'API.
 * N'expose pas l'entité JPA directement.
 * La compagnie et la revue sont représentées par leurs identifiants et noms (pas les entités complètes).
 * Les champs {@code displayTitle}, {@code totalRequiredArtists} et {@code selectedCount} sont calculés côté service (non stockés sur l'entité).
 */
public record ShowDateDto(
        Long id,
        Long companyId,
        String companyName,
        Long cabaretShowId,
        String cabaretShowTitle,
        LocalDate eventDate,
        LocalTime meetingTime,
        String location,
        String clientContactName,
        String clientContactPhone,
        String showDetails,
        ShowDateStatus status,
        String displayTitle,
        int totalRequiredArtists,
        int selectedCount,
        Instant createdAt,
        Instant updatedAt
) {
}
