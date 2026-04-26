package io.violette.cabaretcompany.service;

import io.violette.cabaretcompany.dto.CabaretCompanyDto;
import io.violette.cabaretcompany.dto.CompanyMemberDto;
import io.violette.cabaretcompany.exception.CabaretCompanyNotFoundException;
import io.violette.cabaretcompany.mapper.CabaretCompanyMapper;
import io.violette.cabaretcompany.mapper.CompanyMemberMapper;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CompanyMemberEntity;
import io.violette.cabaretcompany.model.CompanyMemberId;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CompanyMemberRepository;
import io.violette.security.JwtPrincipalInfo;
import io.violette.violetteuser.exception.UserNotFoundException;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * Service du domaine cabaretcompany.
 * Squelette — la logique métier complète (création avec manager automatique, ajout membre, etc.)
 * sera implémentée dans une prochaine étape.
 */
@ApplicationScoped
public class CabaretCompanyService {

    private static final Logger LOG = LoggerFactory.getLogger(CabaretCompanyService.class);
    /**
     * Règle temporaire v0.4.0 :
     * une compagnie unique est utilisée pour éviter de bloquer les démos tant que
     * la gestion multi-compagnies / création autonome n'est pas livrée (v0.5.0).
     */
    public static final String DEFAULT_COMPANY_NAME = "Dream's Production";
    public static final String DEFAULT_COMPANY_DESCRIPTION =
            "Compagnie bootstrap temporaire v0.4.0 (sera remplacée en v0.5.0).";

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CompanyMemberRepository companyMemberRepository;

    @Inject
    CabaretCompanyMapper cabaretCompanyMapper;

    @Inject
    CompanyMemberMapper companyMemberMapper;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Transactional
    public CabaretCompanyEntity ensureDefaultCompanyExists() {
        var existing = cabaretCompanyRepository.findByName(DEFAULT_COMPANY_NAME);
        if (existing.isPresent()) {
            return existing.get();
        }

        var firstManager = violetteUserRepository.findFirstByRole(UserRole.MANAGER);
        if (firstManager.isEmpty()) {
            LOG.info("No MANAGER found yet: default company '{}' will be created when first manager signs up",
                    DEFAULT_COMPANY_NAME);
            return null;
        }

        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(DEFAULT_COMPANY_NAME);
        company.setDescription(DEFAULT_COMPANY_DESCRIPTION);
        company.setManager(firstManager.get());
        cabaretCompanyRepository.persist(company);

        LOG.info("Default company '{}' created with managerId={}", DEFAULT_COMPANY_NAME, firstManager.get().getId());
        return company;
    }

    private CabaretCompanyEntity createDefaultCompanyWithUserAsManager(VioletteUserEntity user) {
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(DEFAULT_COMPANY_NAME);
        company.setDescription(DEFAULT_COMPANY_DESCRIPTION);
        company.setManager(user);
        cabaretCompanyRepository.persist(company);
        return company;
    }

    /**
     * Règle temporaire v0.4.0 :
     * rattacher automatiquement tous les utilisateurs (MANAGER et/ou ARTIST)
     * à la compagnie unique "Dream's Production" afin de rendre la release testable
     * sans écran de gestion de compagnie. Cette logique est transitoire (v0.5.0).
     */
    @Transactional
    public void ensureUserAttachedToDefaultCompany(VioletteUserEntity user) {
        if (user == null || user.getRoles() == null || user.getRoles().isEmpty()) {
            return;
        }

        CabaretCompanyEntity company = ensureDefaultCompanyExists();
        if (company == null) {
            company = createDefaultCompanyWithUserAsManager(user);
            LOG.info("Default company '{}' created during user signup for userId={} (temporary v0.4.0 rule)",
                    DEFAULT_COMPANY_NAME, user.getId());
        }

        if (user.getRoles().contains(UserRole.MANAGER)
                && (company.getManager() == null || !user.getId().equals(company.getManager().getId()))) {
            company.setManager(user);
            LOG.info("Default company '{}' reassigned to managerId={} (temporary v0.4.0 rule)",
                    DEFAULT_COMPANY_NAME, user.getId());
        }

        if (user.getRoles().contains(UserRole.ARTIST)
                && !companyMemberRepository.existsByCompanyIdAndArtistId(company.getId(), user.getId())) {
            CompanyMemberEntity membership = new CompanyMemberEntity();
            membership.setId(new CompanyMemberId(company.getId(), user.getId()));
            membership.setCompany(company);
            membership.setArtist(user);
            companyMemberRepository.persist(membership);
            LOG.info("User userId={} attached as artist member to '{}' (temporary v0.4.0 rule)",
                    user.getId(), DEFAULT_COMPANY_NAME);
        }
    }

    /**
     * Récupère une compagnie par son id.
     *
     * @throws CabaretCompanyNotFoundException si la compagnie n'existe pas
     */
    public CabaretCompanyDto getById(Long id) {
        LOG.debug("Récupération de la compagnie id={}", id);
        return cabaretCompanyRepository.findByIdOptional(id)
                .map(cabaretCompanyMapper::toDto)
                .orElseThrow(CabaretCompanyNotFoundException::new);
    }

    /**
     * Retourne toutes les compagnies gérées par un manager.
     */
    public List<CabaretCompanyDto> getByManagerId(Long managerId) {
        LOG.debug("Récupération des compagnies pour managerId={}", managerId);
        return cabaretCompanyRepository.findByManagerId(managerId).stream()
                .map(cabaretCompanyMapper::toDto)
                .toList();
    }

    /**
     * Retourne la compagnie du manager identifié par le JWT (profil backend via firebaseUid).
     * En Violette, un manager n'a qu'une seule compagnie ; s'il en existe plusieurs en base, la première trouvée est retournée.
     *
     * @throws UserNotFoundException             si aucun profil backend ne correspond au principal JWT
     * @throws CabaretCompanyNotFoundException     si le manager n'a aucune compagnie
     */
    public CabaretCompanyDto getMine(JwtPrincipalInfo principal) {
        Long managerId = violetteUserRepository.findByFirebaseUid(principal.firebaseUid())
                .orElseThrow(UserNotFoundException::new)
                .getId();
        return cabaretCompanyRepository.findByManagerId(managerId).stream()
                .findFirst()
                .map(cabaretCompanyMapper::toDto)
                .orElseThrow(CabaretCompanyNotFoundException::new);
    }

    /**
     * Retourne tous les membres d'une compagnie.
     *
     * @throws CabaretCompanyNotFoundException si la compagnie n'existe pas
     */
    public List<CompanyMemberDto> getMembersByCompanyId(Long companyId) {
        LOG.debug("Récupération des membres pour companyId={}", companyId);
        cabaretCompanyRepository.findByIdOptional(companyId)
                .orElseThrow(CabaretCompanyNotFoundException::new);
        return companyMemberRepository.findByCompanyId(companyId).stream()
                .map(companyMemberMapper::toDto)
                .toList();
    }
}
