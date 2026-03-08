package io.violette.violetteuser.model;

/**
 * Rôle principal d'un utilisateur sur la plateforme Violette.
 * Un gérant peut également être artiste (compétences via artist_skill).
 */
public enum UserRole {
    ARTIST,
    MANAGER
}
