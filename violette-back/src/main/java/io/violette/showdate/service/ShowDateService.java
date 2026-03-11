package io.violette.showdate.service;

import io.violette.cabaretcompany.exception.CabaretCompanyNotFoundException;
import io.violette.cabaretcompany.exception.CabaretShowNotFoundException;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.model.CabaretShowEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.showdate.dto.CreateShowDateRequestDto;
import io.violette.showdate.dto.CreateSkillRequirementRequestDto;
import io.violette.showdate.dto.ShowDateDto;
import io.violette.showdate.dto.ShowDateSkillRequirementDto;
import io.violette.showdate.exception.ShowDateNotFoundException;
import io.violette.showdate.mapper.ShowDateMapper;
import io.violette.showdate.mapper.ShowDateSkillRequirementMapper;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateSkillRequirementEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * Service du domaine showdate.
 * Orchestre la création et la lecture des dates de spectacle et de leurs besoins artistiques.
 */
@ApplicationScoped
public class ShowDateService {

    private static final Logger LOG = LoggerFactory.getLogger(ShowDateService.class);

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ShowDateSkillRequirementRepository skillRequirementRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    CabaretShowRepository cabaretShowRepository;

    @Inject
    ShowDateMapper showDateMapper;

    @Inject
    ShowDateSkillRequirementMapper skillRequirementMapper;

    /**
     * Crée une nouvelle date de spectacle.
     *
     * @throws CabaretCompanyNotFoundException si la compagnie n'existe pas
     * @throws CabaretShowNotFoundException    si la revue est fournie mais introuvable
     */
    @Transactional
    public ShowDateDto createShowDate(CreateShowDateRequestDto request) {
        LOG.info("Création d'une date de spectacle pour companyId={}", request.companyId());

        CabaretCompanyEntity company = cabaretCompanyRepository
                .findByIdOptional(request.companyId())
                .orElseThrow(CabaretCompanyNotFoundException::new);

        CabaretShowEntity cabaretShow = null;
        if (request.cabaretShowId() != null) {
            cabaretShow = cabaretShowRepository
                    .findByIdOptional(request.cabaretShowId())
                    .orElseThrow(CabaretShowNotFoundException::new);
        }

        ShowDateEntity entity = new ShowDateEntity();
        entity.setCompany(company);
        entity.setCabaretShow(cabaretShow);
        entity.setEventDate(request.eventDate());
        entity.setMeetingTime(request.meetingTime());
        entity.setVenueName(request.venueName());
        entity.setAddress(request.address());
        entity.setClientContactName(request.clientContactName());
        entity.setClientContactPhone(request.clientContactPhone());
        entity.setShowDetails(request.showDetails());
        entity.setStatus(ShowDateStatus.PENDING);

        showDateRepository.persist(entity);

        LOG.info("Date de spectacle créée id={} pour companyId={}", entity.getId(), request.companyId());
        return showDateMapper.toDto(entity);
    }

    /**
     * Récupère une date de spectacle par son id.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    public ShowDateDto getById(Long id) {
        LOG.debug("Récupération de la date de spectacle id={}", id);
        return showDateRepository.findByIdOptional(id)
                .map(showDateMapper::toDto)
                .orElseThrow(ShowDateNotFoundException::new);
    }

    /**
     * Retourne toutes les dates de spectacle, triées par date croissante.
     */
    public List<ShowDateDto> getAll() {
        LOG.debug("Récupération de toutes les dates de spectacle");
        return showDateRepository.findAllOrderByEventDateAsc().stream()
                .map(showDateMapper::toDto)
                .toList();
    }

    /**
     * Retourne toutes les dates de spectacle d'une compagnie.
     *
     * @throws CabaretCompanyNotFoundException si la compagnie n'existe pas
     */
    public List<ShowDateDto> getByCompanyId(Long companyId) {
        LOG.debug("Récupération des dates de spectacle pour companyId={}", companyId);
        cabaretCompanyRepository.findByIdOptional(companyId)
                .orElseThrow(CabaretCompanyNotFoundException::new);
        return showDateRepository.findByCompanyId(companyId).stream()
                .map(showDateMapper::toDto)
                .toList();
    }

    /**
     * Ajoute un besoin artistique par compétence à une date de spectacle.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    @Transactional
    public ShowDateSkillRequirementDto addSkillRequirement(Long showDateId, CreateSkillRequirementRequestDto request) {
        LOG.info("Ajout d'un besoin {} pour showDateId={}", request.skill(), showDateId);

        ShowDateEntity showDate = showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);

        ShowDateSkillRequirementEntity entity = new ShowDateSkillRequirementEntity();
        entity.setShowDate(showDate);
        entity.setSkill(request.skill());
        entity.setRequiredCount(request.requiredCount());
        entity.setNetFee(request.netFee());

        skillRequirementRepository.persist(entity);

        LOG.info("Besoin {} ajouté (id={}) pour showDateId={}", request.skill(), entity.getId(), showDateId);
        return skillRequirementMapper.toDto(entity);
    }

    /**
     * Retourne tous les besoins artistiques d'une date de spectacle.
     *
     * @throws ShowDateNotFoundException si la date n'existe pas
     */
    public List<ShowDateSkillRequirementDto> getSkillRequirements(Long showDateId) {
        LOG.debug("Récupération des besoins artistiques pour showDateId={}", showDateId);
        showDateRepository.findByIdOptional(showDateId)
                .orElseThrow(ShowDateNotFoundException::new);
        return skillRequirementRepository.findByShowDateId(showDateId).stream()
                .map(skillRequirementMapper::toDto)
                .toList();
    }
}
