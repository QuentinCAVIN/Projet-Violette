package io.violette.security;

import io.quarkus.security.identity.SecurityIdentity;
import io.quarkus.security.runtime.QuarkusSecurityIdentity;
import io.violette.violetteuser.model.UserRole;
import org.eclipse.microprofile.jwt.JsonWebToken;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.context.control.ActivateRequestContext;
import jakarta.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Enrichit une {@link SecurityIdentity} déjà authentifiée avec les rôles métier
 * chargés depuis la base Violette (source de vérité des rôles).
 * <p>
 * Le principal JWT fournit le {@code sub} (firebaseUid) ; cet augmentor charge
 * l'utilisateur backend et ajoute ses rôles (ARTIST, MANAGER) à l'identité,
 * afin que {@code @RolesAllowed("MANAGER")} fonctionne au runtime.
 * </p>
 * <p>
 * Doit être invoqué dans un contexte de requête actif (ex. via
 * {@link io.quarkus.security.identity.SecurityIdentityAugmentor} avec
 * {@code context.runBlocking(...)}) car il utilise Hibernate/Panache.
 * </p>
 */
@ApplicationScoped
public class VioletteRolesAugmentor {

    private static final Logger LOG = LoggerFactory.getLogger(VioletteRolesAugmentor.class);

    private final VioletteUserRepository violetteUserRepository;

    @Inject
    public VioletteRolesAugmentor(VioletteUserRepository violetteUserRepository) {
        this.violetteUserRepository = violetteUserRepository;
    }

    /**
     * Enrichit l'identité avec les rôles backend de l'utilisateur dont le
     * firebaseUid correspond au nom du principal (claim {@code sub} du JWT).
     * Si l'utilisateur n'existe pas en base, l'identité est retournée sans nouveau rôle.
     *
     * @param identity identité déjà authentifiée (JWT validé par OIDC)
     * @return nouvelle identité avec les rôles backend ajoutés, ou l'identité inchangée
     */
    @ActivateRequestContext
    public SecurityIdentity augment(SecurityIdentity identity) {
        // Firebase UID = claim "sub" du JWT ; getName() peut être un autre claim (preferred_username, etc.).
        String firebaseUid = null;
        if (identity.getPrincipal() instanceof JsonWebToken jwt) {
            firebaseUid = jwt.getSubject();
        }
        if (firebaseUid == null || firebaseUid.isBlank()) {
            firebaseUid = identity.getPrincipal().getName();
        }
        if (firebaseUid == null || firebaseUid.isBlank()) {
            return identity;
        }

        QuarkusSecurityIdentity.Builder builder = QuarkusSecurityIdentity.builder(identity);

        var userOpt = violetteUserRepository.findByFirebaseUid(firebaseUid.trim());
        if (userOpt.isEmpty()) {
            LOG.debug("Aucun utilisateur Violette pour firebaseUid={}, pas de rôle ajouté", firebaseUid);
            return builder.build();
        }

        VioletteUserEntity user = userOpt.get();
        for (UserRole role : user.getRoles()) {
            builder.addRole(role.name());
        }
        LOG.debug("Rôles backend ajoutés pour firebaseUid={}: {}", firebaseUid, user.getRoles());
        return builder.build();
    }
}
