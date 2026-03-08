package io.violette.violetteuser.service;

import io.violette.security.JwtPrincipalInfo;
import io.violette.violetteuser.dto.AuthenticatedUserDto;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Service utilisateur. À cette étape : construit la réponse /me à partir du contexte JWT uniquement.
 * Pas d'accès base, pas de création d'utilisateur.
 */
@ApplicationScoped
public class VioletteUserService {

    /**
     * Construit le DTO de l'utilisateur courant à partir du principal JWT.
     */
    public AuthenticatedUserDto getCurrentUser(JwtPrincipalInfo principal) {
        if (principal == null) {
            return new AuthenticatedUserDto("", "", "");
        }
        return new AuthenticatedUserDto(
                principal.firebaseUid(),
                principal.email(),
                principal.name()
        );
    }
}
