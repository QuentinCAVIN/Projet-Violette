package io.violette.security;

import io.quarkus.security.identity.SecurityIdentity;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.jwt.JsonWebToken;

import java.util.Optional;

/**
 * Fournit le principal authentifié courant sous forme de {@link JwtPrincipalInfo}.
 * Encapsule SecurityIdentity et le cast JWT pour que les controllers et services
 * restent indépendants des types sécurité Quarkus.
 */
@ApplicationScoped
public class CurrentUserContextProvider {

    private final SecurityIdentity securityIdentity;
    private final JwtPrincipalExtractor jwtPrincipalExtractor;

    public CurrentUserContextProvider(SecurityIdentity securityIdentity,
                                     JwtPrincipalExtractor jwtPrincipalExtractor) {
        this.securityIdentity = securityIdentity;
        this.jwtPrincipalExtractor = jwtPrincipalExtractor;
    }

    /**
     * Retourne les infos du principal JWT courant si la requête est authentifiée par un token Bearer JWT.
     */
    public Optional<JwtPrincipalInfo> getCurrentPrincipal() {
        if (securityIdentity.getPrincipal() instanceof JsonWebToken jwt) {
            return Optional.of(jwtPrincipalExtractor.extract(jwt));
        }
        return Optional.empty();
    }
}
