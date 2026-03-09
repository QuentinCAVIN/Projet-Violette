package io.violette.violetteuser.dto;

import io.violette.violetteuser.model.UserRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.Set;

/**
 * DTO de création de profil utilisateur (POST /api/users).
 * firebaseUid et email proviennent du JWT, pas du body.
 */
public record CreateUserRequestDto(
        @NotBlank(message = "firstName ne doit pas être vide")
        @Size(max = 100)
        String firstName,

        @NotBlank(message = "lastName ne doit pas être vide")
        @Size(max = 100)
        String lastName,

        Set<UserRole> roles
) {
    public CreateUserRequestDto {
        roles = roles != null ? Set.copyOf(roles) : null;
    }
}
