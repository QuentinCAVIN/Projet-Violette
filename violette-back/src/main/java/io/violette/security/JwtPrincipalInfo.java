package io.violette.security;

/**
 * Informations extraites du JWT authentifié (Firebase ou compatible).
 * Utilisé pour construire le contexte utilisateur côté service.
 */
public record JwtPrincipalInfo(
        String firebaseUid,
        String email,
        String name
) {
    public JwtPrincipalInfo {
        firebaseUid = firebaseUid != null ? firebaseUid : "";
        email = email != null ? email : "";
        name = name != null ? name : "";
    }
}
