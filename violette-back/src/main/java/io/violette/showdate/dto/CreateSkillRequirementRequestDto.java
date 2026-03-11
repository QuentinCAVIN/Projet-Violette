package io.violette.showdate.dto;

import io.violette.violetteuser.model.ArtistSkill;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

/**
 * DTO d'ajout d'un besoin artistique par compétence (POST /api/show-dates/{id}/skill-requirements).
 */
public record CreateSkillRequirementRequestDto(

        @NotNull(message = "skill est obligatoire")
        ArtistSkill skill,

        @Min(value = 1, message = "requiredCount doit être supérieur ou égal à 1")
        int requiredCount,

        @NotNull(message = "netFee est obligatoire")
        @DecimalMin(value = "0.0", message = "netFee doit être supérieur ou égal à 0")
        BigDecimal netFee
) {
}
