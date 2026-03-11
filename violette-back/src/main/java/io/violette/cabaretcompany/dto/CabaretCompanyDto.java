package io.violette.cabaretcompany.dto;

import java.time.Instant;

/**
 * DTO d'une compagnie exposé par l'API.
 * N'expose pas l'entité JPA directement.
 * Le manager est représenté par son id et son nom (pas l'entité complète).
 */
public record CabaretCompanyDto(
        Long id,
        String name,
        String description,
        Long managerId,
        String managerFirstName,
        String managerLastName,
        Instant createdAt,
        Instant updatedAt
) {
}
