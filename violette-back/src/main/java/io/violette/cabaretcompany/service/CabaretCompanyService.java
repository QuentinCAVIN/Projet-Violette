package io.violette.cabaretcompany.service;

import io.violette.cabaretcompany.dto.CabaretCompanyDto;
import io.violette.cabaretcompany.dto.CompanyMemberDto;
import io.violette.cabaretcompany.exception.CabaretCompanyNotFoundException;
import io.violette.cabaretcompany.mapper.CabaretCompanyMapper;
import io.violette.cabaretcompany.mapper.CompanyMemberMapper;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CompanyMemberRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
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

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CompanyMemberRepository companyMemberRepository;

    @Inject
    CabaretCompanyMapper cabaretCompanyMapper;

    @Inject
    CompanyMemberMapper companyMemberMapper;

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
