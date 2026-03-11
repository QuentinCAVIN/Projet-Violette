package io.violette.cabaretcompany.dto;

import java.time.Instant;

/**
 * DTO d'une revue exposé par l'API.
 * La compagnie est représentée par son id uniquement (pas l'entité complète).
 * Note : "show" est réservé MySQL — le domaine Java utilise CabaretShow, la table SQL s'appelle "revue".
 */
public record CabaretShowDto(
        Long id,
        Long companyId,
        String title,
        String description,
        Instant createdAt,
        Instant updatedAt
) {
}
