package io.violette.security;

import io.quarkus.security.identity.SecurityIdentity;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.jwt.JsonWebToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Optional;

/**
 * Fournit le principal authentifié courant sous forme de {@link JwtPrincipalInfo}.
 * Encapsule SecurityIdentity et le cast JWT pour que les controllers et services
 * restent indépendants des types sécurité Quarkus.
 * En cas d'erreur lors de l'extraction des claims, retourne empty pour éviter un 500 (le controller renverra 401).
 */
@ApplicationScoped
public class CurrentUserContextProvider {

    private static final Logger LOG = LoggerFactory.getLogger(CurrentUserContextProvider.class);

    private final SecurityIdentity securityIdentity;
    private final JwtPrincipalExtractor jwtPrincipalExtractor;

    public CurrentUserContextProvider(SecurityIdentity securityIdentity,
                                     JwtPrincipalExtractor jwtPrincipalExtractor) {
        this.securityIdentity = securityIdentity;
        this.jwtPrincipalExtractor = jwtPrincipalExtractor;
    }

    /**
     * Retourne les infos du principal JWT courant si la requête est authentifiée par un token Bearer JWT.
     * Retourne empty si le principal n'est pas un JWT ou si l'extraction des claims échoue.
     */
    public Optional<JwtPrincipalInfo> getCurrentPrincipal() {
        Object principal = securityIdentity.getPrincipal();
        if (!(principal instanceof JsonWebToken jwt)) {
            return Optional.empty();
        }
        try {
            return Optional.of(jwtPrincipalExtractor.extract(jwt));
        } catch (Exception e) {
            LOG.debug("Impossible d'extraire le principal JWT : {}", e.getMessage());
            return Optional.empty();
        }
    }
}
