package io.violette.violetteuser.dto;

import io.violette.violetteuser.model.ArtistSkill;
import io.violette.violetteuser.model.UserRole;

import java.util.Set;

/**
 * DTO utilisateur exposé par l'API. N'expose pas l'entité JPA.
 * roles : ensemble des rôles (table user_role, aligné avec l'entité).
 * skills : compétences artistiques (table artist_skill).
 */
public record VioletteUserDto(
        Long id,
        String firebaseUid,
        String email,
        String firstName,
        String lastName,
        Set<UserRole> roles,
        Set<ArtistSkill> skills
) {
    public VioletteUserDto {
        roles = roles != null ? Set.copyOf(roles) : Set.of();
        skills = skills != null ? Set.copyOf(skills) : Set.of();
    }
}
