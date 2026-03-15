package io.violette.cabaretcompany.dto;

import java.time.Instant;

/**
 * DTO d'un membre d'une compagnie exposé par l'API.
 * Les champs de la clé composite (companyId, artistId) sont aplatis pour la lisibilité API.
 */
public record CompanyMemberDto(
        Long companyId,
        Long artistId,
        String artistFirstName,
        String artistLastName,
        Instant joinedAt
) {
}
