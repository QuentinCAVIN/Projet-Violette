package io.violette.security;

import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.jwt.JsonWebToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Extrait du JWT authentifié les informations utiles pour le contexte utilisateur.
 * firebaseUid = claim "sub", email et name = claims optionnels (peuvent être absents).
 * Les accès aux claims sont défensifs : toute exception (claim absent, type inattendu)
 * est gérée en retournant une chaîne vide pour éviter un 500.
 */
@ApplicationScoped
public class JwtPrincipalExtractor {

    private static final Logger LOG = LoggerFactory.getLogger(JwtPrincipalExtractor.class);

    private static final String CLAIM_EMAIL = "email";
    private static final String CLAIM_NAME = "name";
    private static final String CLAIM_SUB = "sub";

    /**
     * Construit un JwtPrincipalInfo à partir du token du contexte sécurisé.
     * Aucune exception ne remonte : claims absents ou incohérents donnent des chaînes vides.
     *
     * @param jwt token authentifié (non null, appelé depuis un endpoint @Authenticated)
     * @return informations extraites (jamais null, champs vides si claim absent ou erreur)
     */
    public JwtPrincipalInfo extract(JsonWebToken jwt) {
        if (jwt == null) {
            return new JwtPrincipalInfo("", "", "");
        }
        String sub = getClaimSafe(jwt, CLAIM_SUB, "sub");
        String email = getClaimSafe(jwt, CLAIM_EMAIL, "email");
        String name = getClaimSafe(jwt, CLAIM_NAME, "name");
        return new JwtPrincipalInfo(
                sub != null ? sub : "",
                email != null ? email : "",
                name != null ? name : ""
        );
    }

    /**
     * Récupère un claim en string sans jamais lever d'exception.
     * Quarkus OIDC peut lever (ex. type inattendu, claim manquant selon l'implémentation).
     */
    private static String getClaimSafe(JsonWebToken jwt, String claimName, String logLabel) {
        try {
            Object claim = jwt.getClaim(claimName);
            if (claim == null) {
                return "";
            }
            String value = claim.toString();
            return value != null ? value.trim() : "";
        } catch (Exception e) {
            LOG.debug("Claim JWT '{}' indisponible ou type inattendu : {}", logLabel, e.getMessage());
            return "";
        }
    }
}
