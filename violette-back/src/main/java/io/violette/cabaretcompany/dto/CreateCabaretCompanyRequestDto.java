package io.violette.cabaretcompany.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * DTO de création d'une compagnie (POST /api/companies).
 * Le manager est déduit du JWT (principal courant) côté service — pas dans le body.
 */
public record CreateCabaretCompanyRequestDto(

        @NotBlank(message = "name ne doit pas être vide")
        @Size(max = 255)
        String name,

        String description
) {
}
