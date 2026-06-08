package io.violette.security;

import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.exception.ForbiddenCompanyAccessException;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * Résout la compagnie du MANAGER authentifié à partir de son identité JWT.
 * Centralise la logique de résolution pour éviter la duplication dans les services
 * qui ont besoin de restreindre leurs opérations à la compagnie du manager courant.
 */
@ApplicationScoped
public class ManagerCompanyResolver {

    private static final Logger LOG = LoggerFactory.getLogger(ManagerCompanyResolver.class);

    private final CurrentUserContextProvider currentUserContextProvider;
    private final VioletteUserRepository violetteUserRepository;
    private final CabaretCompanyRepository cabaretCompanyRepository;

    public ManagerCompanyResolver(CurrentUserContextProvider currentUserContextProvider,
                                  VioletteUserRepository violetteUserRepository,
                                  CabaretCompanyRepository cabaretCompanyRepository) {
        this.currentUserContextProvider = currentUserContextProvider;
        this.violetteUserRepository = violetteUserRepository;
        this.cabaretCompanyRepository = cabaretCompanyRepository;
    }

    /**
     * Résout la compagnie du manager authentifié.
     * Enchaîne : principal JWT → utilisateur backend → vérification rôle MANAGER → compagnie.
     * Si l'une des étapes échoue (principal absent, utilisateur introuvable, rôle manquant,
     * aucune compagnie), lève {@link ForbiddenCompanyAccessException}.
     *
     * @return la compagnie dont le manager courant est responsable
     * @throws ForbiddenCompanyAccessException si la compagnie ne peut pas être résolue
     */
    public CabaretCompanyEntity resolveCurrentManagerCompany() {
        JwtPrincipalInfo principal = currentUserContextProvider.getCurrentPrincipal()
                .orElseThrow(() -> {
                    LOG.debug("Résolution compagnie manager : principal JWT absent");
                    return new ForbiddenCompanyAccessException();
                });

        String firebaseUid = principal.firebaseUid();
        LOG.debug("Résolution compagnie manager pour firebaseUid={}", firebaseUid);

        VioletteUserEntity user = violetteUserRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> {
                    LOG.debug("Résolution compagnie manager : utilisateur introuvable pour firebaseUid={}", firebaseUid);
                    return new ForbiddenCompanyAccessException();
                });

        if (!user.getRoles().contains(UserRole.MANAGER)) {
            LOG.debug("Résolution compagnie manager : rôle MANAGER absent pour firebaseUid={}", firebaseUid);
            throw new ForbiddenCompanyAccessException();
        }

        List<CabaretCompanyEntity> companies = cabaretCompanyRepository.findByManagerId(user.getId());
        if (companies.isEmpty()) {
            LOG.debug("Résolution compagnie manager : aucune compagnie trouvée pour firebaseUid={}", firebaseUid);
            throw new ForbiddenCompanyAccessException();
        }

        CabaretCompanyEntity company = companies.getFirst();
        LOG.debug("Compagnie résolue companyId={} pour firebaseUid={}", company.getId(), firebaseUid);
        return company;
    }

    /**
     * Méthode pratique retournant uniquement l'identifiant de la compagnie résolue.
     * Délègue à {@link #resolveCurrentManagerCompany()}.
     *
     * @return l'identifiant de la compagnie du manager courant
     * @throws ForbiddenCompanyAccessException si la compagnie ne peut pas être résolue
     */
    public Long resolveCurrentManagerCompanyId() {
        return resolveCurrentManagerCompany().getId();
    }
}
