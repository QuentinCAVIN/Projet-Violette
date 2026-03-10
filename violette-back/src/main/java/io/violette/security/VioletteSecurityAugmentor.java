package io.violette.security;

import io.quarkus.security.identity.AuthenticationRequestContext;
import io.quarkus.security.identity.SecurityIdentity;
import io.quarkus.security.identity.SecurityIdentityAugmentor;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

/**
 * Augmentor Quarkus qui branche les rôles applicatifs backend Violette sur la
 * {@link SecurityIdentity} après validation du JWT Firebase par OIDC.
 * <p>
 * Pour chaque requête authentifiée :
 * <ol>
 *   <li>Le JWT Firebase est déjà validé par Quarkus OIDC (principal = sub).</li>
 *   <li>Cet augmentor récupère le principal (firebaseUid), charge l'utilisateur
 *       depuis la base Violette et ajoute ses rôles (ARTIST, MANAGER) à l'identité.</li>
 *   <li>Les annotations {@code @RolesAllowed("MANAGER")} deviennent effectives.</li>
 * </ol>
 * La source de vérité des rôles est la base backend, pas les custom claims Firebase.
 * </p>
 */
@ApplicationScoped
public class VioletteSecurityAugmentor implements SecurityIdentityAugmentor {

    private final VioletteRolesAugmentor violetteRolesAugmentor;

    @Inject
    public VioletteSecurityAugmentor(VioletteRolesAugmentor violetteRolesAugmentor) {
        this.violetteRolesAugmentor = violetteRolesAugmentor;
    }

    @Override
    public Uni<SecurityIdentity> augment(SecurityIdentity identity, AuthenticationRequestContext context) {
        if (identity.isAnonymous()) {
            return Uni.createFrom().item(identity);
        }

        // Hibernate/Panache est bloquant ; le contexte de requête est activé dans VioletteRolesAugmentor.
        return context.runBlocking(() -> violetteRolesAugmentor.augment(identity));
    }
}
