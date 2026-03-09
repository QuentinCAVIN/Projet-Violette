package io.violette.violetteuser.dto;

/**
 * DTO représentant l'utilisateur authentifié (contexte JWT).
 * Exposé par GET /api/users/me.
 */
public record AuthenticatedUserDto(
        String firebaseUid,
        String email,
        String name
) {
    public AuthenticatedUserDto {
        firebaseUid = firebaseUid != null ? firebaseUid : "";
        email = email != null ? email : "";
        name = name != null ? name : "";
    }
}
