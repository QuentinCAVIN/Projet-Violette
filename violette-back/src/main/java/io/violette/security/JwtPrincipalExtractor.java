package io.violette.security;

import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.jwt.JsonWebToken;

/**
 * Extrait du JWT authentifié les informations utiles pour le contexte utilisateur.
 * Hypothèses : firebaseUid = sub, email = claim "email", name = claim "name" si présent.
 */
@ApplicationScoped
public class JwtPrincipalExtractor {

    private static final String CLAIM_EMAIL = "email";
    private static final String CLAIM_NAME = "name";
    private static final String CLAIM_SUB = "sub";

    /**
     * Construit un JwtPrincipalInfo à partir du token du contexte sécurisé.
     *
     * @param jwt token authentifié (non null, appelé depuis un endpoint @Authenticated)
     * @return informations extraites (jamais null, champs vides si claim absent)
     */
    public JwtPrincipalInfo extract(JsonWebToken jwt) {
        if (jwt == null) {
            return new JwtPrincipalInfo("", "", "");
        }
        String sub = getClaim(jwt, CLAIM_SUB);
        String email = getClaim(jwt, CLAIM_EMAIL);
        String name = getClaim(jwt, CLAIM_NAME);
        return new JwtPrincipalInfo(sub, email, name);
    }

    private static String getClaim(JsonWebToken jwt, String name) {
        Object claim = jwt.getClaim(name);
        return claim != null ? claim.toString() : "";
    }
}
