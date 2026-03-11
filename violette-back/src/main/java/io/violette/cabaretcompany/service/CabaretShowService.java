package io.violette.cabaretcompany.service;

import io.violette.cabaretcompany.dto.CabaretShowDto;
import io.violette.cabaretcompany.exception.CabaretCompanyNotFoundException;
import io.violette.cabaretcompany.exception.CabaretShowNotFoundException;
import io.violette.cabaretcompany.mapper.CabaretShowMapper;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * Service des revues du domaine cabaretcompany.
 * Squelette — la logique métier complète sera implémentée dans une prochaine étape.
 */
@ApplicationScoped
public class CabaretShowService {

    private static final Logger LOG = LoggerFactory.getLogger(CabaretShowService.class);

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CabaretShowMapper cabaretShowMapper;

    /**
     * Récupère une revue par son id.
     *
     * @throws CabaretShowNotFoundException si la revue n'existe pas
     */
    public CabaretShowDto getById(Long id) {
        LOG.debug("Récupération de la revue id={}", id);
        return cabaretShowRepository.findByIdOptional(id)
                .map(cabaretShowMapper::toDto)
                .orElseThrow(CabaretShowNotFoundException::new);
    }

    /**
     * Retourne toutes les revues d'une compagnie.
     *
     * @throws CabaretCompanyNotFoundException si la compagnie n'existe pas
     */
    public List<CabaretShowDto> getByCompanyId(Long companyId) {
        LOG.debug("Récupération des revues pour companyId={}", companyId);
        cabaretCompanyRepository.findByIdOptional(companyId)
                .orElseThrow(CabaretCompanyNotFoundException::new);
        return cabaretShowRepository.findByCompanyId(companyId).stream()
                .map(cabaretShowMapper::toDto)
                .toList();
    }
}
