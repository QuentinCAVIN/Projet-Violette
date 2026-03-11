package io.violette.showdate.dto;

import io.violette.violetteuser.model.ArtistSkill;

import java.math.BigDecimal;

/**
 * DTO d'un besoin artistique par compétence exposé par l'API.
 * La date de spectacle est représentée par son id uniquement.
 */
public record ShowDateSkillRequirementDto(
        Long id,
        Long showDateId,
        ArtistSkill skill,
        int requiredCount,
        BigDecimal netFee
) {
}
