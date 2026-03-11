package io.violette.cabaretcompany.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * DTO de création d'une revue.
 * La compagnie doit exister en base (validée côté service).
 */
public record CreateCabaretShowRequestDto(

        @NotNull(message = "companyId est requis")
        Long companyId,

        @NotBlank(message = "title ne doit pas être vide")
        @Size(max = 255)
        String title,

        String description
) {
}
